import XCTest
@testable import HeritageOnline

final class NetworkTests: XCTestCase {

    // MARK: - Path Segment Encoding Tests

    func testPathSegmentEncoding() throws {
        // 测试中文编码
        let chinese = HeritageHTTPClient.pathSegment("北京市")
        XCTAssertFalse(chinese.isEmpty)
        XCTAssertTrue(chinese.contains("%"))

        // 测试空格编码
        let withSpace = HeritageHTTPClient.pathSegment("hello world")
        XCTAssertTrue(withSpace.contains("%20") || withSpace.contains("%"))

        // 测试斜杠编码
        let withSlash = HeritageHTTPClient.pathSegment("path/to/resource")
        XCTAssertTrue(withSlash.contains("%2F"))

        // 测试特殊符号编码
        let withSpecial = HeritageHTTPClient.pathSegment("test@#$%")
        XCTAssertTrue(withSpecial.contains("%"))

        // 测试普通字符串不编码
        let normal = HeritageHTTPClient.pathSegment("normal-text_123")
        XCTAssertEqual(normal, "normal-text_123")
    }

    // MARK: - URL Building Tests

    func testBuildURL() throws {
        let client = HeritageHTTPClient.shared

        // 测试基本 URL 构建
        let url1 = try client.buildURL(path: "api/articles")
        XCTAssertTrue(url1.absoluteString.contains("api/articles"))

        // 测试带查询参数的 URL
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pageSize", value: "20")
        ]
        let url2 = try client.buildURL(path: "api/articles", queryItems: queryItems)
        XCTAssertTrue(url2.absoluteString.contains("page=1"))
        XCTAssertTrue(url2.absoluteString.contains("pageSize=20"))

        // 测试空查询参数不添加
        let url3 = try client.buildURL(path: "api/articles", queryItems: [])
        XCTAssertFalse(url3.absoluteString.contains("?"))

        // 测试 nil 值被过滤
        let queryItemsWithNil = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "keywords", value: nil)
        ]
        let url4 = try client.buildURL(path: "api/articles", queryItems: queryItemsWithNil)
        XCTAssertTrue(url4.absoluteString.contains("page=1"))
        XCTAssertFalse(url4.absoluteString.contains("keywords"))
    }

    // MARK: - QueryBuilder Tests

    func testQueryBuilder() throws {
        var builder = QueryBuilder()

        // 测试添加字符串参数
        builder.add("category", value: "news" as String?)
        builder.add("keywords", value: nil as String?) // 应该被忽略
        builder.add("region", value: "" as String?) // 应该被忽略

        // 测试添加整数参数
        builder.add("page", value: 1 as Int?)
        builder.add("pageSize", value: nil as Int?) // 应该被忽略

        // 测试添加布尔参数
        builder.add("hasImage", value: true as Bool?)
        builder.add("featured", value: nil as Bool?) // 应该被忽略

        // 测试添加数组参数
        builder.add("types", values: ["article", "directoryItem"])
        builder.add("empty", values: []) // 应该被忽略

        let items = builder.build()

        // 验证结果
        XCTAssertEqual(items.count, 4) // category, page, hasImage, types
        XCTAssertTrue(items.contains { $0.name == "category" && $0.value == "news" })
        XCTAssertTrue(items.contains { $0.name == "page" && $0.value == "1" })
        XCTAssertTrue(items.contains { $0.name == "hasImage" && $0.value == "true" })
        XCTAssertTrue(items.contains { $0.name == "types" && $0.value == "article,directoryItem" })
    }

    // MARK: - NetworkError Tests

    func testNetworkErrorDescriptions() throws {
        // 测试错误描述不为空
        XCTAssertFalse(NetworkError.invalidBaseURL.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.invalidURL.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.invalidResponse.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.badRequest.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.notFound.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.serverError.localizedDescription.isEmpty)
        XCTAssertFalse(NetworkError.httpError(statusCode: 500).localizedDescription.isEmpty)
    }

    func testNetworkErrorFromNSError() throws {
        // 测试从 NSError 转换
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let networkError = NetworkError.from(nsError)
        // 错误描述应该不为空
        XCTAssertFalse(networkError.localizedDescription.isEmpty)
    }

    // MARK: - Query Model Tests

    func testArticleQueryDefaults() throws {
        let query = ArticleQuery()
        XCTAssertEqual(query.category, .news)
        XCTAssertEqual(query.page, 1)
        XCTAssertEqual(query.pageSize, 20)
        XCTAssertNil(query.year)
        XCTAssertNil(query.keywords)
    }

    func testDirectoryItemQueryDefaults() throws {
        let query = DirectoryItemQuery()
        XCTAssertEqual(query.kind, .nationalProject)
        XCTAssertEqual(query.page, 1)
        XCTAssertEqual(query.pageSize, 20)
        XCTAssertNil(query.keywords)
        XCTAssertNil(query.region)
        XCTAssertNil(query.category)
        XCTAssertNil(query.year)
        XCTAssertNil(query.listType)
    }

    func testInheritorQueryDefaults() throws {
        let query = InheritorQuery()
        XCTAssertEqual(query.page, 1)
        XCTAssertEqual(query.pageSize, 20)
        XCTAssertNil(query.keywords)
        XCTAssertNil(query.region)
        XCTAssertNil(query.category)
        XCTAssertNil(query.year)
        XCTAssertNil(query.gender)
    }

    func testSearchV2QueryDefaults() throws {
        let query = SearchV2Query(keywords: "test")
        XCTAssertEqual(query.keywords, "test")
        XCTAssertTrue(query.types.isEmpty)
        XCTAssertEqual(query.page, 1)
        XCTAssertEqual(query.pageSize, 20)
        XCTAssertNil(query.region)
        XCTAssertNil(query.category)
        XCTAssertNil(query.year)
        XCTAssertNil(query.kind)
        XCTAssertNil(query.hasImage)
    }

    func testTimelineV2QueryDefaults() throws {
        let query = TimelineV2Query()
        XCTAssertNil(query.year)
        XCTAssertTrue(query.types.isEmpty)
        XCTAssertEqual(query.page, 1)
        XCTAssertEqual(query.pageSize, 20)
    }

    // MARK: - Enum Wire Name Tests

    func testArticleCategoryWireNames() throws {
        XCTAssertEqual(ArticleCategory.news.wireName, "news")
        XCTAssertEqual(ArticleCategory.forum.wireName, "forum")
        XCTAssertEqual(ArticleCategory.specialTopic.wireName, "specialTopic")
    }

    func testDirectoryItemKindWireNames() throws {
        XCTAssertEqual(DirectoryItemKind.nationalProject.wireName, "nationalProject")
        XCTAssertEqual(DirectoryItemKind.culturalEcoZone.wireName, "culturalEcoZone")
        XCTAssertEqual(DirectoryItemKind.productiveProtectionBase.wireName, "productiveProtectionBase")
        XCTAssertEqual(DirectoryItemKind.unescoEntry.wireName, "unescoEntry")
        XCTAssertEqual(DirectoryItemKind.chinaUnescoEntry.wireName, "chinaUnescoEntry")
        XCTAssertEqual(DirectoryItemKind.contractingState.wireName, "contractingState")
    }

    func testSearchResultTypeWireNames() throws {
        XCTAssertEqual(SearchResultType.article.wireName, "article")
        XCTAssertEqual(SearchResultType.directoryItem.wireName, "directoryItem")
        XCTAssertEqual(SearchResultType.inheritor.wireName, "inheritor")
    }

    func testTaxonomyRegionSortWireNames() throws {
        XCTAssertEqual(TaxonomyRegionSort.total.wireName, "total")
        XCTAssertEqual(TaxonomyRegionSort.directoryItem.wireName, "directoryItem")
        XCTAssertEqual(TaxonomyRegionSort.inheritor.wireName, "inheritor")
    }
}
