import XCTest
@testable import HeritageOnline

/// ArticlesViewModel 单元测试
/// 覆盖：加载、分页、筛选、防重入
@preconcurrency @MainActor
final class ArticlesViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!
    var viewModel: ArticlesViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
        viewModel = ArticlesViewModel(repository: mockRepository, debounceNanoseconds: 0)
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

    func testLoadArticlesClearsAppendError() async {
        // Given - 首次加载成功
        let page1 = [
            createArticleSummary(id: "1", title: "文章1")
        ]
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: page1, page: 1, pageSize: 20, total: 2, hasMore: true)
        )
        await viewModel.loadArticles()

        // Given - loadMore 失败
        mockRepository.articlesResult = .failure(NetworkError.networkUnavailable)
        await viewModel.loadMore()
        XCTAssertNotNil(viewModel.uiState.appendError)

        // When - 重新加载成功
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [createArticleSummary(id: "2", title: "文章2")], page: 1, pageSize: 20, total: 1, hasMore: false)
        )
        await viewModel.loadArticles()

        // Then - appendError 被清理
        XCTAssertNil(viewModel.uiState.appendError)
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
        await viewModel.waitForPendingCategoryTask()

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
        await viewModel.applyYearFilter("20ab")

        // Then - 校验错误写入 validationError，不写入 error
        XCTAssertNotNil(viewModel.uiState.validationError)
        XCTAssertNil(viewModel.uiState.error)
        XCTAssertTrue(viewModel.uiState.yearFilter.isEmpty)
    }

    func testApplyYearFilterValidYear() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When - 有效年份
        await viewModel.applyYearFilter("2024")

        // Then
        XCTAssertEqual(viewModel.uiState.yearFilter, "2024")
        XCTAssertNil(viewModel.uiState.error)
    }

    // MARK: - Query 参数验证

    func testApplyYearFilterPassesYearToQuery() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )

        // When
        await viewModel.applyYearFilter("2024")

        // Then - 验证年份传入 query
        XCTAssertNotNil(mockRepository.lastArticleQuery)
        XCTAssertEqual(mockRepository.lastArticleQuery?.year, 2024)
    }

    func testSelectCategoryPassesCategoryToQuery() async {
        // Given
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.loadArticles()
        mockRepository.articlesCallCount = 0

        // When
        viewModel.selectCategory(.forum)
        await viewModel.waitForPendingCategoryTask()

        // Then - 验证分类传入 query
        XCTAssertNotNil(mockRepository.lastArticleQuery)
        XCTAssertEqual(mockRepository.lastArticleQuery?.category, .forum)
    }

    func testClearYearFilterClearsQueryYear() async {
        // Given - 先设置年份
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyYearFilter("2024")
        XCTAssertEqual(mockRepository.lastArticleQuery?.year, 2024)

        // When - 清除年份
        await viewModel.clearYearFilter()

        // Then - query 中 year 为 nil
        XCTAssertNil(mockRepository.lastArticleQuery?.year)
        XCTAssertTrue(viewModel.uiState.yearFilter.isEmpty)
    }

    // MARK: - validationError 清理

    func testLoadArticlesClearsValidationError() async {
        // Given - 先触发校验错误
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyYearFilter("20ab")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 重新加载
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [createArticleSummary(id: "1", title: "文章1")], page: 1, pageSize: 20, total: 1, hasMore: false)
        )
        await viewModel.loadArticles()

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
    }

    func testClearYearFilterClearsValidationError() async {
        // Given - 先触发校验错误
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyYearFilter("20ab")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 清除年份
        await viewModel.clearYearFilter()

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
    }

    func testClearFiltersClearsValidationError() async {
        // Given - 先触发校验错误
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyYearFilter("20ab")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 清除所有筛选
        await viewModel.clearFilters()

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
    }

    func testDismissValidationError() async {
        // Given - 先触发校验错误
        mockRepository.articlesResult = .success(
            PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
        )
        await viewModel.applyYearFilter("20ab")
        XCTAssertNotNil(viewModel.uiState.validationError)

        // When - 关闭校验错误
        viewModel.dismissValidationError()

        // Then - validationError 被清理
        XCTAssertNil(viewModel.uiState.validationError)
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
