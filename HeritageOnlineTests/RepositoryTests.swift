import XCTest
@testable import HeritageOnline

final class RepositoryTests: XCTestCase {

    // MARK: - ArticleDetailLookup Tests

    func testArticleDetailLookupDefaults() throws {
        let lookup = ArticleDetailLookup()
        XCTAssertNil(lookup.articleId)
        XCTAssertNil(lookup.sourceId)
        XCTAssertNil(lookup.sourceUrl)
        XCTAssertEqual(lookup.category, .news)
    }

    func testArticleDetailLookupWithArticleId() throws {
        let lookup = ArticleDetailLookup(articleId: "article-1")
        XCTAssertEqual(lookup.articleId, "article-1")
        XCTAssertNil(lookup.sourceId)
        XCTAssertNil(lookup.sourceUrl)
    }

    func testArticleDetailLookupWithSourceId() throws {
        let lookup = ArticleDetailLookup(sourceId: "source-1", category: .forum)
        XCTAssertNil(lookup.articleId)
        XCTAssertEqual(lookup.sourceId, "source-1")
        XCTAssertEqual(lookup.category, .forum)
    }

    func testArticleDetailLookupWithSourceUrl() throws {
        let lookup = ArticleDetailLookup(sourceUrl: "https://example.com/article")
        XCTAssertNil(lookup.articleId)
        XCTAssertNil(lookup.sourceId)
        XCTAssertEqual(lookup.sourceUrl, "https://example.com/article")
    }

    // MARK: - DirectoryDetailLookup Tests

    func testDirectoryDetailLookupDefaults() throws {
        let lookup = DirectoryDetailLookup()
        XCTAssertNil(lookup.itemId)
        XCTAssertNil(lookup.sourceId)
        XCTAssertEqual(lookup.kind, .nationalProject)
    }

    func testDirectoryDetailLookupWithItemId() throws {
        let lookup = DirectoryDetailLookup(itemId: "dir-1")
        XCTAssertEqual(lookup.itemId, "dir-1")
        XCTAssertNil(lookup.sourceId)
    }

    func testDirectoryDetailLookupWithSourceId() throws {
        let lookup = DirectoryDetailLookup(sourceId: "source-1", kind: .culturalEcoZone)
        XCTAssertNil(lookup.itemId)
        XCTAssertEqual(lookup.sourceId, "source-1")
        XCTAssertEqual(lookup.kind, .culturalEcoZone)
    }

    // MARK: - InheritorDetailLookup Tests

    func testInheritorDetailLookupDefaults() throws {
        let lookup = InheritorDetailLookup()
        XCTAssertNil(lookup.inheritorId)
        XCTAssertNil(lookup.sourceId)
    }

    func testInheritorDetailLookupWithInheritorId() throws {
        let lookup = InheritorDetailLookup(inheritorId: "inheritor-1")
        XCTAssertEqual(lookup.inheritorId, "inheritor-1")
        XCTAssertNil(lookup.sourceId)
    }

    func testInheritorDetailLookupWithSourceId() throws {
        let lookup = InheritorDetailLookup(sourceId: "source-1")
        XCTAssertNil(lookup.inheritorId)
        XCTAssertEqual(lookup.sourceId, "source-1")
    }

    // MARK: - Mock Repository Tests

    func testMockRepositoryCanReplaceRealImplementation() throws {
        let mock = MockHeritageRepository()

        // 验证 mock 可以被当作 HeritageRepository 使用
        let repository: HeritageRepository = mock
        XCTAssertNotNil(repository)
    }

    func testMockRepositoryCallCounts() async throws {
        let mock = MockHeritageRepository()

        // 测试调用计数
        XCTAssertEqual(mock.homeBannersCallCount, 0)
        XCTAssertEqual(mock.articlesCallCount, 0)
        XCTAssertEqual(mock.articleCallCount, 0)

        // 调用方法
        _ = try await mock.homeBanners()
        XCTAssertEqual(mock.homeBannersCallCount, 1)

        _ = try await mock.articles(query: ArticleQuery())
        XCTAssertEqual(mock.articlesCallCount, 1)

        _ = try await mock.article(id: "test")
        XCTAssertEqual(mock.articleCallCount, 1)
    }

    func testMockRepositoryReturnsConfiguredResults() async throws {
        let mock = MockHeritageRepository()

        // 配置返回结果
        let expectedArticle = ArticleSummaryDTO(
            id: "test-id",
            title: "测试文章",
            summary: "测试摘要",
            category: "news",
            imageUrl: nil,
            publishedAt: nil,
            sourceUrl: nil
        )
        mock.articlesResult = .success(
            PagedResultDTO(items: [expectedArticle], page: 1, pageSize: 20, totalCount: 1, hasMore: false)
        )

        // 调用并验证
        let result = try await mock.articles(query: ArticleQuery())
        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.items.first?.id, "test-id")
        XCTAssertEqual(result.items.first?.title, "测试文章")
    }

    func testMockRepositoryCanThrowErrors() async throws {
        let mock = MockHeritageRepository()

        // 配置错误
        mock.articleResult = .failure(NetworkError.notFound)

        // 验证错误传播
        do {
            _ = try await mock.article(id: "test")
            XCTFail("应该抛出错误")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }

    // MARK: - Detail Lookup Priority Tests

    func testArticleDetailLookupPriority() async throws {
        let mock = MockHeritageRepository()

        // 测试：当有 articleId 时，应该使用 articleId
        let lookup1 = ArticleDetailLookup(articleId: "article-1", sourceId: "source-1")
        XCTAssertEqual(lookup1.articleId, "article-1")
        XCTAssertEqual(lookup1.sourceId, "source-1")

        // 测试：当没有 articleId 但有 sourceId 时，应该使用 sourceId
        let lookup2 = ArticleDetailLookup(sourceId: "source-1")
        XCTAssertNil(lookup2.articleId)
        XCTAssertEqual(lookup2.sourceId, "source-1")

        // 测试：当只有 sourceUrl 时，应该使用 sourceUrl
        let lookup3 = ArticleDetailLookup(sourceUrl: "https://example.com")
        XCTAssertNil(lookup3.articleId)
        XCTAssertNil(lookup3.sourceId)
        XCTAssertEqual(lookup3.sourceUrl, "https://example.com")
    }

    func testDirectoryDetailLookupPriority() async throws {
        // 测试：当有 itemId 时，应该使用 itemId
        let lookup1 = DirectoryDetailLookup(itemId: "dir-1", sourceId: "source-1")
        XCTAssertEqual(lookup1.itemId, "dir-1")
        XCTAssertEqual(lookup1.sourceId, "source-1")

        // 测试：当没有 itemId 但有 sourceId 时，应该使用 sourceId
        let lookup2 = DirectoryDetailLookup(sourceId: "source-1")
        XCTAssertNil(lookup2.itemId)
        XCTAssertEqual(lookup2.sourceId, "source-1")
    }

    func testInheritorDetailLookupPriority() async throws {
        // 测试：当有 inheritorId 时，应该使用 inheritorId
        let lookup1 = InheritorDetailLookup(inheritorId: "inheritor-1", sourceId: "source-1")
        XCTAssertEqual(lookup1.inheritorId, "inheritor-1")
        XCTAssertEqual(lookup1.sourceId, "source-1")

        // 测试：当没有 inheritorId 但有 sourceId 时，应该使用 sourceId
        let lookup2 = InheritorDetailLookup(sourceId: "source-1")
        XCTAssertNil(lookup2.inheritorId)
        XCTAssertEqual(lookup2.sourceId, "source-1")
    }
}
