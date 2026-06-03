import XCTest
@testable import HeritageOnline

/// 详情 ViewModel 单元测试
/// 覆盖：ArticleDetailViewModel、DirectoryDetailViewModel、InheritorDetailViewModel
@MainActor
final class DetailViewModelTests: XCTestCase {
    var mockRepository: MockHeritageRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockHeritageRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - ArticleDetailViewModel

    func testArticleDetailLoadSuccess() async {
        // Given
        let article = createArticleDetail(id: "test", title: "测试文章")
        mockRepository.articleResult = .success(article)
        let viewModel = ArticleDetailViewModel(articleId: "test", repository: mockRepository)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertNotNil(viewModel.uiState.article)
        XCTAssertEqual(viewModel.uiState.article?.title, "测试文章")
        XCTAssertFalse(viewModel.uiState.isLoading)
        XCTAssertNil(viewModel.uiState.error)
    }

    func testArticleDetailLoadFailure() async {
        // Given
        mockRepository.articleResult = .failure(NetworkError.notFound)
        let viewModel = ArticleDetailViewModel(articleId: "test", repository: mockRepository)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertNil(viewModel.uiState.article)
        XCTAssertNotNil(viewModel.uiState.error)
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    func testArticleDetailStaleContentOnRefreshFailure() async {
        // Given - 首次加载成功
        let article = createArticleDetail(id: "test", title: "测试文章")
        mockRepository.articleResult = .success(article)
        let viewModel = ArticleDetailViewModel(articleId: "test", repository: mockRepository)
        await viewModel.refresh()
        XCTAssertNotNil(viewModel.uiState.article)

        // Given - 刷新失败
        mockRepository.articleResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.refresh()

        // Then - 标记为过期，保留旧数据
        XCTAssertNotNil(viewModel.uiState.article)
        XCTAssertTrue(viewModel.uiState.isContentStale)
        XCTAssertNil(viewModel.uiState.error)
    }

    func testArticleDetailLookupPriority() async {
        // Given
        let article = createArticleDetail(id: "test", title: "测试文章")
        mockRepository.articleResult = .success(article)
        let viewModel = ArticleDetailViewModel(
            articleId: "id1",
            sourceId: "sid1",
            sourceUrl: "http://example.com",
            repository: mockRepository
        )

        // When
        await viewModel.refresh()

        // Then - 应该通过 mockRepository 记录验证 lookup 优先级
        XCTAssertNotNil(mockRepository.lastArticleLookup)
        XCTAssertEqual(mockRepository.lastArticleLookup?.articleId, "id1")
        XCTAssertEqual(mockRepository.lastArticleLookup?.sourceId, "sid1")
        XCTAssertEqual(mockRepository.lastArticleLookup?.sourceUrl, "http://example.com")
        XCTAssertEqual(mockRepository.articleCallCount, 1)
        XCTAssertEqual(mockRepository.articleBySourceIdCallCount, 0)
        XCTAssertEqual(mockRepository.articleBySourceUrlCallCount, 0)
    }

    // MARK: - DirectoryDetailViewModel

    func testDirectoryDetailLoadSuccess() async {
        // Given
        let item = createDirectoryItemDetail(id: "test", title: "测试名录")
        mockRepository.directoryItemResult = .success(item)
        let viewModel = DirectoryDetailViewModel(itemId: "test", repository: mockRepository)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertNotNil(viewModel.uiState.item)
        XCTAssertEqual(viewModel.uiState.item?.title, "测试名录")
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    func testDirectoryDetailLookupPriority() async {
        // Given
        let item = createDirectoryItemDetail(id: "test", title: "测试名录")
        mockRepository.directoryItemResult = .success(item)
        let viewModel = DirectoryDetailViewModel(
            itemId: "did1",
            sourceId: "dsid1",
            kind: .nationalProject,
            repository: mockRepository
        )

        // When
        await viewModel.refresh()

        // Then - 通过 mockRepository 记录验证 lookup 参数
        XCTAssertNotNil(mockRepository.lastDirectoryLookup)
        XCTAssertEqual(mockRepository.lastDirectoryLookup?.itemId, "did1")
        XCTAssertEqual(mockRepository.lastDirectoryLookup?.sourceId, "dsid1")
        XCTAssertEqual(mockRepository.directoryItemCallCount, 1)
        XCTAssertEqual(mockRepository.directoryItemBySourceIdCallCount, 0)
    }

    func testDirectoryDetailStaleContent() async {
        // Given - 首次加载成功
        let item = createDirectoryItemDetail(id: "test", title: "测试名录")
        mockRepository.directoryItemResult = .success(item)
        let viewModel = DirectoryDetailViewModel(itemId: "test", repository: mockRepository)
        await viewModel.refresh()

        // Given - 刷新失败
        mockRepository.directoryItemResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertTrue(viewModel.uiState.isContentStale)
        XCTAssertNotNil(viewModel.uiState.item)
    }

    // MARK: - InheritorDetailViewModel

    func testInheritorDetailLoadSuccess() async {
        // Given
        let inheritor = createInheritorDetail(id: "test", name: "测试传承人")
        mockRepository.inheritorResult = .success(inheritor)
        let viewModel = InheritorDetailViewModel(inheritorId: "test", repository: mockRepository)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertNotNil(viewModel.uiState.item)
        XCTAssertEqual(viewModel.uiState.item?.name, "测试传承人")
        XCTAssertFalse(viewModel.uiState.isLoading)
    }

    func testInheritorDetailLookupPriority() async {
        // Given
        let inheritor = createInheritorDetail(id: "test", name: "测试传承人")
        mockRepository.inheritorResult = .success(inheritor)
        let viewModel = InheritorDetailViewModel(
            inheritorId: "iid1",
            sourceId: "isid1",
            repository: mockRepository
        )

        // When
        await viewModel.refresh()

        // Then - 通过 mockRepository 记录验证 lookup 参数
        XCTAssertNotNil(mockRepository.lastInheritorLookup)
        XCTAssertEqual(mockRepository.lastInheritorLookup?.inheritorId, "iid1")
        XCTAssertEqual(mockRepository.lastInheritorLookup?.sourceId, "isid1")
        XCTAssertEqual(mockRepository.inheritorCallCount, 1)
        XCTAssertEqual(mockRepository.inheritorBySourceIdCallCount, 0)
    }

    func testInheritorDetailStaleContent() async {
        // Given - 首次加载成功
        let inheritor = createInheritorDetail(id: "test", name: "测试传承人")
        mockRepository.inheritorResult = .success(inheritor)
        let viewModel = InheritorDetailViewModel(inheritorId: "test", repository: mockRepository)
        await viewModel.refresh()

        // Given - 刷新失败
        mockRepository.inheritorResult = .failure(NetworkError.networkUnavailable)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertTrue(viewModel.uiState.isContentStale)
        XCTAssertNotNil(viewModel.uiState.item)
    }

    // MARK: - Helpers

    private func createArticleDetail(id: String, title: String) -> ArticleDetailDTO {
        ArticleDetailDTO(
            id: id,
            category: nil,
            title: title,
            summary: nil,
            publishedAt: nil,
            coverImage: nil,
            sourceUrl: nil,
            sourceName: nil,
            author: nil,
            editor: nil,
            contentBlocks: [],
            relatedArticles: []
        )
    }

    private func createDirectoryItemDetail(id: String, title: String) -> DirectoryItemDetailDTO {
        DirectoryItemDetailDTO(
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
            nominationType: nil,
            protectionUnit: nil,
            coverImage: nil,
            sourceUrl: nil,
            gallery: [],
            contentBlocks: [],
            relatedProjects: [],
            relatedInheritors: [],
            relatedDocuments: []
        )
    }

    private func createInheritorDetail(id: String, name: String) -> InheritorDetailDTO {
        InheritorDetailDTO(
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
            sourceUrl: nil,
            contentBlocks: [],
            relatedProjects: [],
            relatedInheritors: []
        )
    }
}


