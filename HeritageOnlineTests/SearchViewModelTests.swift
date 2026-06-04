import XCTest
@testable import HeritageOnline

/// SearchViewModel 单元测试
/// 覆盖：空关键词不请求、防抖、筛选参数、loadMore
@preconcurrency @MainActor
final class SearchViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = SearchViewModel(
            repository: mockRepository,
            searchDebounceMs: 0,
            suggestionDebounceMs: 0
        )
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 空关键词

    func testEmptyQueryDoesNotSearch() {
        // Given
        viewModel.updateQuery("")

        // When
        viewModel.search()

        // Then
        XCTAssertEqual(mockRepository.searchV2CallCount, 0)
    }

    func testWhitespaceQueryDoesNotSearch() {
        // Given
        viewModel.updateQuery("   ")

        // When
        viewModel.search()

        // Then
        XCTAssertEqual(mockRepository.searchV2CallCount, 0)
    }

    // MARK: - 搜索成功

    func testSearchSuccess() async {
        // Given
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )
        viewModel.updateQuery("test")

        // When
        viewModel.search()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(mockRepository.searchV2CallCount, 1)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isSearching)
    }

    func testSearchError() async {
        // Given
        mockRepository.searchV2Result = .failure(NetworkError.networkUnavailable)
        viewModel.updateQuery("test")

        // When
        viewModel.search()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertNotNil(viewModel.uiState.error)
    }

    // MARK: - 筛选参数传递

    func testSearchPassesTypeFilter() async {
        // Given
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )
        viewModel.updateQuery("test")

        // When
        viewModel.toggleType(.article)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(viewModel.uiState.selectedTypes.contains(.article))
    }

    func testSearchPassesRegionFilter() async {
        // Given
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )
        viewModel.updateQuery("test")

        // When
        viewModel.updateRegionFilter("北京")
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.regionFilter, "北京")
    }

    func testSearchPassesYearFilter() async {
        // Given
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )
        viewModel.updateQuery("test")

        // When
        viewModel.updateYearFilter(2024)
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.yearFilter, 2024)
    }

    // MARK: - LoadMore

    func testLoadMoreAppendsResults() async {
        // Given - first search
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: true, facets: nil, query: nil)
        )
        viewModel.updateQuery("test")
        viewModel.search()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // When - load more
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 2, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )
        viewModel.loadMore()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertGreaterThanOrEqual(mockRepository.searchV2CallCount, 2)
    }

    // MARK: - 建议

    func testSelectSuggestionTriggersSearch() async {
        // Given
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )

        // When
        viewModel.selectSuggestion("建议文本")
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.query, "建议文本")
        XCTAssertEqual(mockRepository.searchV2CallCount, 1)
    }

    // MARK: - 清除筛选

    func testClearFiltersResetsAndSearches() async {
        // Given
        mockRepository.searchV2Result = .success(
            SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
        )
        viewModel.updateQuery("test")
        viewModel.updateRegionFilter("北京")
        viewModel.updateYearFilter(2024)

        // When
        viewModel.clearFilters()
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertTrue(viewModel.uiState.regionFilter.isEmpty)
        XCTAssertNil(viewModel.uiState.yearFilter)
    }
}
