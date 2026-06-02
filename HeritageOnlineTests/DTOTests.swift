import XCTest
@testable import HeritageOnline

final class DTOTests: XCTestCase {

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    // MARK: - Common DTOs Tests

    func testMediaAssetDTO() throws {
        let json = """
        {
            "sourceUrl": "https://example.com/source.jpg",
            "originalUrl": "https://example.com/original.jpg",
            "displayUrl": "https://example.com/display.jpg",
            "thumbnailUrl": "https://example.com/thumb.jpg",
            "altText": "Test image"
        }
        """

        let result = try decoder.decode(MediaAssetDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.sourceUrl, "https://example.com/source.jpg")
        XCTAssertEqual(result.originalUrl, "https://example.com/original.jpg")
        XCTAssertEqual(result.displayUrl, "https://example.com/display.jpg")
        XCTAssertEqual(result.thumbnailUrl, "https://example.com/thumb.jpg")
        XCTAssertEqual(result.altText, "Test image")
    }

    func testMediaAssetDTOWithMissingFields() throws {
        let json = """
        {}
        """

        let result = try decoder.decode(MediaAssetDTO.self, from: json.data(using: .utf8)!)

        XCTAssertNil(result.sourceUrl)
        XCTAssertNil(result.originalUrl)
        XCTAssertNil(result.displayUrl)
        XCTAssertNil(result.thumbnailUrl)
        XCTAssertNil(result.altText)
    }

    func testProblemDetailsDTO() throws {
        let json = """
        {
            "type": "https://example.com/errors/not-found",
            "title": "Not Found",
            "status": 404,
            "detail": "The requested resource was not found",
            "instance": "/api/articles/123"
        }
        """

        let result = try decoder.decode(ProblemDetailsDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.type, "https://example.com/errors/not-found")
        XCTAssertEqual(result.title, "Not Found")
        XCTAssertEqual(result.status, 404)
        XCTAssertEqual(result.detail, "The requested resource was not found")
        XCTAssertEqual(result.instance, "/api/articles/123")
    }

    // MARK: - Article DTOs Tests

    func testArticleSummaryDTO() throws {
        let json = """
        {
            "id": "article-1",
            "category": "news",
            "title": "测试文章标题",
            "summary": "这是文章摘要",
            "publishedAt": "2024-01-15T10:00:00Z",
            "imageUrl": "https://example.com/image.jpg",
            "sourceUrl": "https://example.com/article"
        }
        """

        let result = try decoder.decode(ArticleSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "article-1")
        XCTAssertEqual(result.category, "news")
        XCTAssertEqual(result.title, "测试文章标题")
        XCTAssertEqual(result.summary, "这是文章摘要")
        XCTAssertEqual(result.publishedAt, "2024-01-15T10:00:00Z")
        XCTAssertEqual(result.imageUrl, "https://example.com/image.jpg")
        XCTAssertEqual(result.sourceUrl, "https://example.com/article")
    }

    func testArticleSummaryDTOWithMissingFields() throws {
        let json = """
        {
            "id": "test-id"
        }
        """

        let result = try decoder.decode(ArticleSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "test-id")
        XCTAssertNil(result.title)
        XCTAssertNil(result.summary)
        XCTAssertNil(result.publishedAt)
        XCTAssertNil(result.imageUrl)
        XCTAssertNil(result.sourceUrl)
    }

    func testArticleDetailDTO() throws {
        let json = """
        {
            "id": "article-1",
            "category": "forum",
            "title": "论坛文章",
            "summary": "论坛文章摘要",
            "publishedAt": "2024-01-15",
            "author": "张三",
            "content": "正文内容"
        }
        """

        let result = try decoder.decode(ArticleDetailDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "article-1")
        XCTAssertEqual(result.category, "forum")
        XCTAssertEqual(result.author, "张三")
        XCTAssertEqual(result.content, "正文内容")
    }

    // MARK: - Directory DTOs Tests

    func testDirectoryItemSummaryDTO() throws {
        let json = """
        {
            "id": "dir-1",
            "kind": "nationalProject",
            "title": "国家级项目",
            "summary": "项目摘要",
            "category": "传统技艺",
            "region": "北京市",
            "projectCode": "I-1"
        }
        """

        let result = try decoder.decode(DirectoryItemSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "dir-1")
        XCTAssertEqual(result.kind, "nationalProject")
        XCTAssertEqual(result.title, "国家级项目")
        XCTAssertEqual(result.category, "传统技艺")
        XCTAssertEqual(result.region, "北京市")
        XCTAssertEqual(result.projectCode, "I-1")
    }

    func testDirectoryItemKindEnum() throws {
        // 测试所有 wire value
        XCTAssertEqual(DirectoryItemKind.nationalProject.rawValue, "nationalProject")
        XCTAssertEqual(DirectoryItemKind.culturalEcoZone.rawValue, "culturalEcoZone")
        XCTAssertEqual(DirectoryItemKind.productiveProtectionBase.rawValue, "productiveProtectionBase")
        XCTAssertEqual(DirectoryItemKind.unescoEntry.rawValue, "unescoEntry")
        XCTAssertEqual(DirectoryItemKind.chinaUnescoEntry.rawValue, "chinaUnescoEntry")
        XCTAssertEqual(DirectoryItemKind.contractingState.rawValue, "contractingState")
    }

    func testDirectoryItemDetailDTO() throws {
        let json = """
        {
            "id": "dir-1",
            "kind": "culturalEcoZone",
            "title": "文化生态保护区",
            "batch": "第一批",
            "publishedYear": 2006
        }
        """

        let result = try decoder.decode(DirectoryItemDetailDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "dir-1")
        XCTAssertEqual(result.kind, "culturalEcoZone")
        XCTAssertEqual(result.batch, "第一批")
        XCTAssertEqual(result.publishedYear, 2006)
    }

    // MARK: - Inheritor DTOs Tests

    func testInheritorSummaryDTO() throws {
        let json = """
        {
            "id": "inheritor-1",
            "name": "张三",
            "gender": "男",
            "ethnicity": "汉族",
            "category": "传统技艺",
            "projectName": "景泰蓝制作技艺",
            "region": "北京市"
        }
        """

        let result = try decoder.decode(InheritorSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "inheritor-1")
        XCTAssertEqual(result.name, "张三")
        XCTAssertEqual(result.gender, "男")
        XCTAssertEqual(result.ethnicity, "汉族")
        XCTAssertEqual(result.category, "传统技艺")
        XCTAssertEqual(result.projectName, "景泰蓝制作技艺")
        XCTAssertEqual(result.region, "北京市")
    }

    func testInheritorDetailDTO() throws {
        let json = """
        {
            "id": "inheritor-1",
            "name": "张三",
            "description": "简介内容"
        }
        """

        let result = try decoder.decode(InheritorDetailDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "inheritor-1")
        XCTAssertEqual(result.name, "张三")
        XCTAssertEqual(result.description, "简介内容")
    }

    // MARK: - Home DTOs Tests

    func testHomeBannerDTO() throws {
        let json = """
        {
            "id": "banner-1",
            "title": "Banner Title",
            "subtitle": "Banner Subtitle",
            "imageUrl": "https://example.com/banner.jpg",
            "linkUrl": "https://example.com"
        }
        """

        let result = try decoder.decode(HomeBannerDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "banner-1")
        XCTAssertEqual(result.title, "Banner Title")
        XCTAssertEqual(result.subtitle, "Banner Subtitle")
        XCTAssertEqual(result.imageUrl, "https://example.com/banner.jpg")
        XCTAssertEqual(result.linkUrl, "https://example.com")
    }

    func testHomeFeedDTO() throws {
        let json = """
        {
            "banners": [
                {"id": "banner-1", "title": "Banner"}
            ],
            "articles": [
                {"id": "article-1", "category": "news", "title": "新闻"}
            ]
        }
        """

        let result = try decoder.decode(HomeFeedDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.banners.count, 1)
        XCTAssertEqual(result.articles.count, 1)
    }

    // MARK: - Edge Cases Tests

    func testUnknownFieldsDoNotCrash() throws {
        let json = """
        {
            "id": "test",
            "unknownField": "value",
            "anotherUnknown": 123,
            "nestedUnknown": {"key": "value"}
        }
        """

        let result = try decoder.decode(ArticleSummaryDTO.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(result.id, "test")
    }

    func testNullFieldsDoNotCrash() throws {
        let json = """
        {
            "id": "test-id",
            "title": null,
            "summary": null
        }
        """

        let result = try decoder.decode(ArticleSummaryDTO.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(result.id, "test-id")
        XCTAssertNil(result.title)
        XCTAssertNil(result.summary)
    }

    func testEmptyArraysDefault() throws {
        let json = """
        {
            "id": "test"
        }
        """

        let result = try decoder.decode(ArticleDetailDTO.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(result.contentBlocks.count, 0) // 现在是非可选，默认空数组
    }

    func testArticleCategoryEnum() throws {
        // 测试 ArticleCategory enum JSON 解码
        let newsJson = "\"news\""
        let newsResult = try decoder.decode(ArticleCategory.self, from: newsJson.data(using: .utf8)!)
        XCTAssertEqual(newsResult, .news)

        let forumJson = "\"forum\""
        let forumResult = try decoder.decode(ArticleCategory.self, from: forumJson.data(using: .utf8)!)
        XCTAssertEqual(forumResult, .forum)

        let specialTopicJson = "\"specialTopic\""
        let specialTopicResult = try decoder.decode(ArticleCategory.self, from: specialTopicJson.data(using: .utf8)!)
        XCTAssertEqual(specialTopicResult, .specialTopic)

        // 测试所有 wireName
        XCTAssertEqual(ArticleCategory.news.wireName, "news")
        XCTAssertEqual(ArticleCategory.forum.wireName, "forum")
        XCTAssertEqual(ArticleCategory.specialTopic.wireName, "specialTopic")
    }

    // MARK: - Search DTOs Tests

    func testSearchResultItemDTO() throws {
        let json = """
        {
            "id": "result-1",
            "title": "搜索结果",
            "type": "article",
            "category": "news"
        }
        """

        let result = try decoder.decode(SearchResultItemDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "result-1")
        XCTAssertEqual(result.title, "搜索结果")
        XCTAssertEqual(result.type, "article")
        XCTAssertEqual(result.category, "news")
    }

    func testTimelineItemDTO() throws {
        let json = """
        {
            "id": "timeline-1",
            "title": "时间线项",
            "type": "directoryItem",
            "year": 2006
        }
        """

        let result = try decoder.decode(TimelineItemDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "timeline-1")
        XCTAssertEqual(result.title, "时间线项")
        XCTAssertEqual(result.type, "directoryItem")
        XCTAssertEqual(result.year, 2006)
    }
}
