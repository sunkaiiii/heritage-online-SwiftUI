import XCTest
@testable import HeritageOnline

/// InheritorsViewModel 单元测试
/// 覆盖：列表加载、分页、筛选参数传递
@preconcurrency @MainActor
final class InheritorsViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: InheritorsViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = InheritorsViewModel(repository: mockRepository, listCache: NoOpListCacheRepository(), debounceNanoseconds: 0)
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
            createInheritor(id: "1", name: "传承人1"),
            createInheritor(id: "2", name: "传承人2")
        ]
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: items, page: 1, pageSize: 20, total: 2, hasMore: false)
        )

        // When
        await viewModel.loadItems()

        // Then
        XCTAssertEqual(viewModel.uiState.items.count, 2)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
    }

    func testLoadItemsFailure() async {
        // Given
        mockRepository.inheritorsResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.loadItems()

        // Then
        XCTAssertTrue(viewModel.uiState.items.isEmpty)
        XCTAssertNotNil(viewModel.uiState.error)
    }

    // MARK: - 分页

    func testLoadMoreAppendsToList() async {
        // Given - 首次加载
        let page1 = [createInheritor(id: "1", name: "传承人1")]
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadItems()

        // Given - 第二页
        let page2 = [createInheritor(id: "2", name: "传承人2")]
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: page2, page: 2, pageSize: 20, total: 2, hasMore: false)
        )

        // When
        await viewModel.loadMore()

        // Then
        XCTAssertEqual(viewModel.uiState.items.count, 2)
        XCTAssertEqual(viewModel.uiState.currentPage, 2)
        XCTAssertFalse(viewModel.uiState.hasMore)
    }

    func testLoadMoreFailurePreservesList() async {
        // Given - 首次加载成功
        let page1 = [createInheritor(id: "1", name: "传承人1")]
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadItems()

        // Given - 第二页失败
        mockRepository.inheritorsResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.loadMore()

        // Then - 保留已有列表
        XCTAssertEqual(viewModel.uiState.items.count, 1)
        XCTAssertNotNil(viewModel.uiState.appendError)
    }

    func testLoadItemsClearsAppendError() async {
        // Given - 首次加载成功
        let page1 = [createInheritor(id: "1", name: "传承人1")]
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadItems()

        // Given - loadMore 失败
        mockRepository.inheritorsResult = .failure(NetworkError.networkUnavailable)
        await viewModel.loadMore()
        XCTAssertNotNil(viewModel.uiState.appendError)

        // When - 重新加载成功
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [createInheritor(id: "2", name: "传承人2")], page: 1, pageSize: 20, total: 1, hasMore: false)
        )
        await viewModel.loadItems()

        // Then - appendError 被清理
        XCTAssertNil(viewModel.uiState.appendError)
    }

    // MARK: - 筛选

    func testApplyFiltersValidatesYear() async {
        // Given
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 无效年份
        await viewModel.applyFilters(region: "", category: "", year: "20ab", gender: "")

        // Then - 校验错误写入 validationError，不写入 error
        XCTAssertNotNil(viewModel.uiState.validationError)
        XCTAssertNil(viewModel.uiState.error)
    }

    func testApplyFiltersValidYear() async {
        // Given
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 有效年份
        await viewModel.applyFilters(region: "北京", category: "", year: "2024", gender: "")

        // Then
        XCTAssertEqual(viewModel.uiState.regionFilter, "北京")
        XCTAssertEqual(viewModel.uiState.yearFilter, "2024")
        XCTAssertNil(viewModel.uiState.error)
    }

    func testClearFilterField() async {
        // Given
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyFilters(region: "北京", category: "传统音乐", year: "2024", gender: "male")

        // When
        await viewModel.clearFilterField(.region)

        // Then
        XCTAssertTrue(viewModel.uiState.regionFilter.isEmpty)
        XCTAssertEqual(viewModel.uiState.categoryFilter, "传统音乐")
    }

    // MARK: - Query 参数验证

    func testApplyFiltersPassesAllParamsToQuery() async {
        // Given
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When
        await viewModel.applyFilters(region: "北京", category: "传统音乐", year: "2024", gender: "male")

        // Then - 验证所有筛选参数传入 query
        XCTAssertNotNil(mockRepository.lastInheritorQuery)
        XCTAssertEqual(mockRepository.lastInheritorQuery?.region, "北京")
        XCTAssertEqual(mockRepository.lastInheritorQuery?.category, "传统音乐")
        XCTAssertEqual(mockRepository.lastInheritorQuery?.year, 2024)
        XCTAssertEqual(mockRepository.lastInheritorQuery?.gender, "male")
    }

    func testClearAdvancedFiltersClearsQuery() async {
        // Given - 先设置筛选
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyFilters(region: "北京", category: "传统音乐", year: "2024", gender: "male")

        // When - 清除所有筛选
        await viewModel.clearAdvancedFilters()

        // Then - query 中所有筛选字段为 nil
        XCTAssertNil(mockRepository.lastInheritorQuery?.region)
        XCTAssertNil(mockRepository.lastInheritorQuery?.category)
        XCTAssertNil(mockRepository.lastInheritorQuery?.year)
        XCTAssertNil(mockRepository.lastInheritorQuery?.gender)
    }

    // MARK: - validationError 清理

    func testLoadItemsClearsValidationError() async {
        // Given - 先触发校验错误
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyFilters(region: "", category: "", year: "20ab", gender: "")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 重新加载
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [createInheritor(id: "1", name: "传承人1")], page: 1, pageSize: 20, total: 1, hasMore: false)
        )
        await viewModel.loadItems()

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
    }

    func testClearFilterFieldClearsValidationError() async {
        // Given - 先触发校验错误
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyFilters(region: "", category: "", year: "20ab", gender: "")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 清除单个筛选字段
        await viewModel.clearFilterField(.year)

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
    }

    func testClearAdvancedFiltersClearsValidationError() async {
        // Given - 先触发校验错误
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyFilters(region: "", category: "", year: "20ab", gender: "")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 清除所有筛选
        await viewModel.clearAdvancedFilters()

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
    }

    // MARK: - Helpers

    private func createInheritor(id: String, name: String) -> InheritorSummaryDTO {
        InheritorSummaryDTO(
            id: id,
            name: name,
            gender: nil,
            birthDateText: nil,
            ethnicity: nil,
            category: nil,
            projectCode: nil,
            projectName: nil,
            region: nil,
            batch: nil,
            description: nil,
            coverImage: nil,
            sourceUrl: nil
        )
    }
}
