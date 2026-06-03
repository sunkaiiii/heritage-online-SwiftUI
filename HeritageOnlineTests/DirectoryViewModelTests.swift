import XCTest
@testable import HeritageOnline

/// DirectoryViewModel 单元测试
/// 覆盖：列表加载、分页、筛选、统计 tab、kind 切换
@MainActor
final class DirectoryViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: DirectoryViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = DirectoryViewModel(repository: mockRepository, debounceNanoseconds: 0)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 列表加载

    func testLoadItemsSuccess() async {
        // Given
        let items = [
            createDirectoryItem(id: "1", title: "名录1"),
            createDirectoryItem(id: "2", title: "名录2")
        ]
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: items, page: 1, pageSize: 20, total: 2, hasMore: false)
        )

        // When
        await viewModel.loadItems()

        // Then
        XCTAssertEqual(viewModel.uiState.items.count, 2)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
    }

    func testLoadMoreAppendsToList() async {
        // Given - 首次加载
        let page1 = [createDirectoryItem(id: "1", title: "名录1")]
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadItems()

        // Given - 第二页
        let page2 = [createDirectoryItem(id: "2", title: "名录2")]
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: page2, page: 2, pageSize: 20, total: 2, hasMore: false)
        )

        // When
        await viewModel.loadMore()

        // Then
        XCTAssertEqual(viewModel.uiState.items.count, 2)
        XCTAssertEqual(viewModel.uiState.currentPage, 2)
    }

    func testLoadItemsClearsAppendError() async {
        // Given - 首次加载成功
        let page1 = [createDirectoryItem(id: "1", title: "名录1")]
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadItems()

        // Given - loadMore 失败
        mockRepository.directoryItemsResult = .failure(NetworkError.networkUnavailable)
        await viewModel.loadMore()
        XCTAssertNotNil(viewModel.uiState.appendError)

        // When - 重新加载成功
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: [createDirectoryItem(id: "2", title: "名录2")], page: 1, pageSize: 20, total: 1, hasMore: false)
        )
        await viewModel.loadItems()

        // Then - appendError 被清理
        XCTAssertNil(viewModel.uiState.appendError)
    }

    // MARK: - 统计

    func testLoadStatisticsSuccess() async {
        // Given
        let overview = DirectoryStatisticsOverviewDTO(
            kind: "nationalProject",
            total: 100,
            generatedAt: "2024-01-01",
            dimensions: []
        )
        mockRepository.directoryStatisticsOverviewResult = .success(overview)
        mockRepository.directoryStatisticsBreakdownResult = .success(
            DirectoryStatisticDimensionDTO(dimension: "year", items: [])
        )

        // When
        await viewModel.loadStatistics()

        // Then
        XCTAssertNotNil(viewModel.uiState.statisticsState.overview)
        XCTAssertEqual(viewModel.uiState.statisticsState.overview?.total, 100)
        XCTAssertFalse(viewModel.uiState.statisticsState.isLoading)
        XCTAssertNil(viewModel.uiState.statisticsState.error)
    }

    func testStatisticsFailureDoesNotAffectList() async {
        // Given - 列表加载成功
        let items = [createDirectoryItem(id: "1", title: "名录1")]
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: items, page: 1, pageSize: 20, total: 1, hasMore: false)
        )
        await viewModel.loadItems()
        XCTAssertEqual(viewModel.uiState.items.count, 1)

        // Given - 统计加载失败
        mockRepository.directoryStatisticsOverviewResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.loadStatistics()

        // Then - 列表数据不受影响
        XCTAssertEqual(viewModel.uiState.items.count, 1)
        XCTAssertNotNil(viewModel.uiState.statisticsState.error)
    }

    // MARK: - Kind 切换

    func testSelectKindReloadsItems() async {
        // Given
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.loadItems()
        mockRepository.directoryItemsCallCount = 0

        // When
        viewModel.selectKind(.culturalEcoZone)

        // 等待 Task 完成
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.selectedKind, .culturalEcoZone)
        XCTAssertEqual(mockRepository.directoryItemsCallCount, 1)
    }

    // MARK: - Tab 切换

    func testSelectStatisticsTabLoadsStatistics() async {
        // Given
        mockRepository.directoryStatisticsOverviewResult = .success(
            DirectoryStatisticsOverviewDTO(kind: nil, total: 0, generatedAt: nil, dimensions: [])
        )
        mockRepository.directoryStatisticsBreakdownResult = .success(
            DirectoryStatisticDimensionDTO(dimension: nil, items: [])
        )

        // When
        viewModel.selectTab(.statistics)

        // 等待 Task 完成
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.selectedTab, .statistics)
        XCTAssertEqual(mockRepository.directoryStatisticsOverviewCallCount, 1)
    }

    // MARK: - 筛选

    func testApplyFiltersValidatesYear() async {
        // Given
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 无效年份
        await viewModel.applyFilters(region: "", category: "", year: "20ab", listType: "")

        // Then - 校验错误写入 validationError，不写入 error
        XCTAssertNotNil(viewModel.uiState.validationError)
        XCTAssertNil(viewModel.uiState.error)
    }

    // MARK: - Query 参数验证

    func testApplyFiltersPassesAllParamsToQuery() async {
        // Given
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When
        await viewModel.applyFilters(region: "北京", category: "传统音乐", year: "2024", listType: "第一批")

        // Then - 验证所有筛选参数传入 query
        XCTAssertNotNil(mockRepository.lastDirectoryItemQuery)
        XCTAssertEqual(mockRepository.lastDirectoryItemQuery?.region, "北京")
        XCTAssertEqual(mockRepository.lastDirectoryItemQuery?.category, "传统音乐")
        XCTAssertEqual(mockRepository.lastDirectoryItemQuery?.year, 2024)
        XCTAssertEqual(mockRepository.lastDirectoryItemQuery?.listType, "第一批")
    }

    func testClearAdvancedFiltersClearsQuery() async {
        // Given - 先设置筛选
        mockRepository.directoryItemsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyFilters(region: "北京", category: "", year: "2024", listType: "")

        // When - 清除所有筛选
        await viewModel.clearAdvancedFilters()

        // Then - query 中所有筛选字段为 nil
        XCTAssertNil(mockRepository.lastDirectoryItemQuery?.region)
        XCTAssertNil(mockRepository.lastDirectoryItemQuery?.year)
    }

    // MARK: - Helpers

    private func createDirectoryItem(id: String, title: String) -> DirectoryItemSummaryDTO {
        DirectoryItemSummaryDTO(
            id: id,
            kind: nil,
            title: title,
            summary: nil,
            category: nil,
            region: nil,
            projectCode: nil,
            batch: nil,
            publishedYear: nil,
            listType: nil,
            coverImage: nil,
            sourceUrl: nil
        )
    }
}
