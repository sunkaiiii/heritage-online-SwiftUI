import XCTest
@testable import HeritageOnline

/// InheritorsViewModel 单元测试
/// 覆盖：列表加载、分页、筛选参数传递
@MainActor
final class InheritorsViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: InheritorsViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = InheritorsViewModel(repository: mockRepository)
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

    // MARK: - 筛选

    func testApplyFiltersValidatesYear() async {
        // Given
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 无效年份
        viewModel.applyFilters(region: "", category: "", year: "20ab", gender: "")

        // Then
        XCTAssertNotNil(viewModel.uiState.error)
    }

    func testApplyFiltersValidYear() async {
        // Given
        mockRepository.inheritorsResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 有效年份
        viewModel.applyFilters(region: "北京", category: "", year: "2024", gender: "")
        try? await Task.sleep(nanoseconds: 100_000_000)

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
        viewModel.applyFilters(region: "北京", category: "传统音乐", year: "2024", gender: "male")
        try? await Task.sleep(nanoseconds: 100_000_000)

        // When
        viewModel.clearFilterField(.region)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(viewModel.uiState.regionFilter.isEmpty)
        XCTAssertEqual(viewModel.uiState.categoryFilter, "传统音乐")
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
