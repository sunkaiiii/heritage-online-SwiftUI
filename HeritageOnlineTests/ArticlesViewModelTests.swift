import XCTest
@testable import HeritageOnline

/// ArticlesViewModel 单元测试
/// 覆盖：加载、分页、筛选、防重入
@MainActor
final class ArticlesViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: ArticlesViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = ArticlesViewModel(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - loadArticles

    func testLoadArticlesSuccess() async {
        // Given
        let articles = [
            createArticleSummary(id: "1", title: "文章1"),
            createArticleSummary(id: "2", title: "文章2")
        ]
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: articles, page: 1, pageSize: 20, total: 2, hasMore: false)
        )

        // When
        await viewModel.loadArticles()

        // Then
        XCTAssertEqual(viewModel.uiState.articles.count, 2)
        XCTAssertEqual(viewModel.uiState.currentPage, 1)
        XCTAssertFalse(viewModel.uiState.hasMore)
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertEqual(mockRepository.articlesCallCount, 1)
    }

    func testLoadArticlesFailure() async {
        // Given
        mockRepository.articlesResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.loadArticles()

        // Then
        XCTAssertTrue(viewModel.uiState.articles.isEmpty)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    // MARK: - loadMore

    func testLoadMoreAppendsToList() async {
        // Given - 首次加载
        let page1 = [
            createArticleSummary(id: "1", title: "文章1")
        ]
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadArticles()
        XCTAssertEqual(viewModel.uiState.articles.count, 1)

        // Given - 第二页
        let page2 = [
            createArticleSummary(id: "2", title: "文章2")
        ]
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: page2, page: 2, pageSize: 20, total: 2, hasMore: false)
        )

        // When
        await viewModel.loadMore()

        // Then
        XCTAssertEqual(viewModel.uiState.articles.count, 2)
        XCTAssertEqual(viewModel.uiState.currentPage, 2)
        XCTAssertFalse(viewModel.uiState.hasMore)
        XCTAssertNil(viewModel.uiState.appendError)
    }

    func testLoadMoreFailurePreservesExistingList() async {
        // Given - 首次加载成功
        let page1 = [
            createArticleSummary(id: "1", title: "文章1")
        ]
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadArticles()
        XCTAssertEqual(viewModel.uiState.articles.count, 1)

        // Given - 第二页失败
        mockRepository.articlesResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.loadMore()

        // Then - 保留已有列表
        XCTAssertEqual(viewModel.uiState.articles.count, 1)
        XCTAssertNotNil(viewModel.uiState.appendError)
    }

    func testLoadMoreDoesNotLoadWhenNoMore() async {
        // Given - 首次加载，没有更多
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.loadArticles()

        // When
        await viewModel.loadMore()

        // Then - 只调用了一次（首次加载）
        XCTAssertEqual(mockRepository.articlesCallCount, 1)
    }

    // MARK: - 筛选

    func testSelectCategoryReloadsArticles() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.loadArticles()
        mockRepository.articlesCallCount = 0

        // When
        viewModel.selectCategory(.forum)
        try? await Task.sleep(nanoseconds: 400_000_000) // 等待防抖

        // Then
        XCTAssertEqual(viewModel.uiState.selectedCategory, .forum)
        XCTAssertEqual(mockRepository.articlesCallCount, 1)
    }

    func testSelectSameCategoryDoesNotReload() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.loadArticles()
        mockRepository.articlesCallCount = 0

        // When - 选择相同分类
        viewModel.selectCategory(.news)

        // Then - 不会重新加载
        XCTAssertEqual(mockRepository.articlesCallCount, 0)
    }

    func testApplyYearFilterValidatesInput() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 无效年份
        viewModel.applyYearFilter("20ab")

        // Then
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertTrue(viewModel.uiState.yearFilter.isEmpty)
    }

    func testApplyYearFilterValidYear() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 有效年份
        viewModel.applyYearFilter("2024")
        try? await Task.sleep(nanoseconds: 100_000_000)

        // Then
        XCTAssertEqual(viewModel.uiState.yearFilter, "2024")
        XCTAssertNil(viewModel.uiState.error)
    }

    // MARK: - Helpers

    private func createArticleSummary(id: String, title: String) -> ArticleSummaryDTO {
        ArticleSummaryDTO(
            id: id,
            category: nil,
            title: title,
            summary: nil,
            publishedAt: nil,
            coverImage: nil,
            sourceUrl: nil
        )
    }
}
