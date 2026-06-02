import XCTest
@testable import HeritageOnline

final class DTOTests: XCTestCase {

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()

    // MARK: - Fixture Helper

    private func loadFixture(name: String) throws -> Data {
        guard let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json") else {
            // 如果找不到 bundle，尝试直接从文件系统加载
            let path = "HeritageOnlineTests/Fixtures/\(name).json"
            if let data = FileManager.default.contents(atPath: path) {
                return data
            }
            throw NSError(domain: "DTOTests", code: 404, userInfo: [NSLocalizedDescriptionKey: "Fixture \(name).json not found"])
        }
        return try Data(contentsOf: url)
    }

    // MARK: - Fixture-based Tests

    func testPagedResultFromFixture() throws {
        let json = """
        {
            "items": [{"id": "1", "category": "news", "title": "测试"}],
            "page": 1,
            "pageSize": 20,
            "total": 100,
            "hasMore": true
        }
        """

        let result = try decoder.decode(PagedResultDTO<ArticleSummaryDTO>.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.items.count, 1)
        XCTAssertEqual(result.page, 1)
        XCTAssertEqual(result.pageSize, 20)
        XCTAssertEqual(result.total, 100)
        XCTAssertTrue(result.hasMore)
    }

    func testArticleDetailFromFixture() throws {
        let json = """
        {
            "id": "1",
            "category": "news",
            "title": "测试文章详情",
            "summary": "这是一篇测试文章的摘要",
            "publishedAt": "2024-01-15",
            "coverImage": {
                "sourceUrl": "https://example.com/image.jpg",
                "displayUrl": "https://example.com/image_display.jpg"
            },
            "sourceName": "测试来源",
            "author": "测试作者",
            "contentBlocks": [
                {"type": "heading", "text": "第一章"},
                {"type": "text", "text": "正文内容"},
                {"type": "image", "image": {"sourceUrl": "https://example.com/content_image.jpg"}}
            ],
            "relatedArticles": [
                {"title": "相关文章", "sourceId": "related-1"}
            ]
        }
        """

        let result = try decoder.decode(ArticleDetailDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "1")
        XCTAssertEqual(result.title, "测试文章详情")
        XCTAssertNotNil(result.coverImage)
        XCTAssertEqual(result.coverImage?.displayUrl, "https://example.com/image_display.jpg")
        XCTAssertEqual(result.sourceName, "测试来源")
        XCTAssertEqual(result.author, "测试作者")
        XCTAssertEqual(result.contentBlocks.count, 3)
        XCTAssertEqual(result.relatedArticles.count, 1)
    }

    func testHomeFeedFromFixture() throws {
        let json = """
        {
            "banners": [{"id": "banner-1", "sortOrder": 1}],
            "latestNews": [{"id": "news-1", "category": "news", "title": "最新新闻"}],
            "latestSpecialTopics": [{"id": "special-1", "category": "specialTopic", "title": "专题文章"}],
            "latestForumArticles": [{"id": "forum-1", "category": "forum", "title": "论坛文章"}],
            "featuredDirectoryItems": [{"id": "dir-1", "kind": "nationalProject", "title": "国家级项目"}],
            "featuredInheritors": [{"id": "inheritor-1", "name": "传承人姓名"}],
            "summary": {
                "totalArticles": 1000,
                "totalDirectoryItems": 500,
                "totalInheritors": 200
            }
        }
        """

        let result = try decoder.decode(HomeFeedDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.banners.count, 1)
        XCTAssertEqual(result.latestNews.count, 1)
        XCTAssertEqual(result.latestSpecialTopics.count, 1)
        XCTAssertEqual(result.latestForumArticles.count, 1)
        XCTAssertEqual(result.featuredDirectoryItems.count, 1)
        XCTAssertEqual(result.featuredInheritors.count, 1)
        XCTAssertNotNil(result.summary)
        XCTAssertEqual(result.summary?.totalArticles, 1000)
    }

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
            "publishedAt": "2024-01-15",
            "coverImage": {
                "displayUrl": "https://example.com/image.jpg"
            },
            "sourceUrl": "https://example.com/article"
        }
        """

        let result = try decoder.decode(ArticleSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "article-1")
        XCTAssertEqual(result.category, "news")
        XCTAssertEqual(result.title, "测试文章标题")
        XCTAssertEqual(result.summary, "这是文章摘要")
        XCTAssertEqual(result.publishedAt, "2024-01-15")
        XCTAssertNotNil(result.coverImage)
        XCTAssertEqual(result.coverImage?.displayUrl, "https://example.com/image.jpg")
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
        XCTAssertNil(result.coverImage)
        XCTAssertNil(result.sourceUrl)
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
            "projectCode": "I-1",
            "batch": "第一批",
            "publishedYear": 2006,
            "listType": "代表作名录",
            "coverImage": {
                "displayUrl": "https://example.com/dir.jpg"
            }
        }
        """

        let result = try decoder.decode(DirectoryItemSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "dir-1")
        XCTAssertEqual(result.kind, "nationalProject")
        XCTAssertEqual(result.title, "国家级项目")
        XCTAssertEqual(result.category, "传统技艺")
        XCTAssertEqual(result.region, "北京市")
        XCTAssertEqual(result.projectCode, "I-1")
        XCTAssertEqual(result.batch, "第一批")
        XCTAssertEqual(result.publishedYear, 2006)
        XCTAssertEqual(result.listType, "代表作名录")
        XCTAssertNotNil(result.coverImage)
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
            "publishedYear": 2006,
            "listType": "代表作名录",
            "nominationType": "申报类型",
            "protectionUnit": "保护单位",
            "gallery": [
                {"displayUrl": "https://example.com/gallery1.jpg"},
                {"displayUrl": "https://example.com/gallery2.jpg"}
            ],
            "contentBlocks": [
                {"type": "text", "text": "正文内容"}
            ],
            "relatedProjects": [
                {"title": "相关项目", "sourceId": "related-dir-1"}
            ],
            "relatedInheritors": [
                {"title": "相关传承人", "sourceId": "related-inheritor-1"}
            ],
            "relatedDocuments": [
                {"title": "相关文献", "sourceId": "related-doc-1"}
            ]
        }
        """

        let result = try decoder.decode(DirectoryItemDetailDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "dir-1")
        XCTAssertEqual(result.kind, "culturalEcoZone")
        XCTAssertEqual(result.batch, "第一批")
        XCTAssertEqual(result.publishedYear, 2006)
        XCTAssertEqual(result.listType, "代表作名录")
        XCTAssertEqual(result.nominationType, "申报类型")
        XCTAssertEqual(result.protectionUnit, "保护单位")
        XCTAssertEqual(result.gallery.count, 2)
        XCTAssertEqual(result.contentBlocks.count, 1)
        XCTAssertEqual(result.relatedProjects.count, 1)
        XCTAssertEqual(result.relatedInheritors.count, 1)
        XCTAssertEqual(result.relatedDocuments.count, 1)
    }

    // MARK: - Inheritor DTOs Tests

    func testInheritorSummaryDTO() throws {
        let json = """
        {
            "id": "inheritor-1",
            "name": "张三",
            "gender": "男",
            "birthDateText": "1950年",
            "ethnicity": "汉族",
            "category": "传统技艺",
            "projectCode": "I-1",
            "projectName": "景泰蓝制作技艺",
            "region": "北京市",
            "batch": "第一批",
            "description": "简介",
            "coverImage": {
                "displayUrl": "https://example.com/inheritor.jpg"
            },
            "sourceUrl": "https://example.com/inheritor/1"
        }
        """

        let result = try decoder.decode(InheritorSummaryDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "inheritor-1")
        XCTAssertEqual(result.name, "张三")
        XCTAssertEqual(result.gender, "男")
        XCTAssertEqual(result.birthDateText, "1950年")
        XCTAssertEqual(result.ethnicity, "汉族")
        XCTAssertEqual(result.category, "传统技艺")
        XCTAssertEqual(result.projectCode, "I-1")
        XCTAssertEqual(result.projectName, "景泰蓝制作技艺")
        XCTAssertEqual(result.region, "北京市")
        XCTAssertEqual(result.batch, "第一批")
        XCTAssertNotNil(result.coverImage)
        XCTAssertNotNil(result.sourceUrl)
    }

    func testInheritorDetailDTO() throws {
        let json = """
        {
            "id": "inheritor-1",
            "name": "张三",
            "description": "简介内容",
            "contentBlocks": [
                {"type": "text", "text": "正文"}
            ],
            "relatedProjects": [
                {"title": "相关项目", "kind": "nationalProject"}
            ],
            "relatedInheritors": [
                {"title": "相关传承人"}
            ]
        }
        """

        let result = try decoder.decode(InheritorDetailDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "inheritor-1")
        XCTAssertEqual(result.name, "张三")
        XCTAssertEqual(result.description, "简介内容")
        XCTAssertEqual(result.contentBlocks.count, 1)
        XCTAssertEqual(result.relatedProjects.count, 1)
        XCTAssertEqual(result.relatedInheritors.count, 1)
    }

    // MARK: - Home DTOs Tests

    func testHomeBannerDTO() throws {
        let json = """
        {
            "id": "banner-1",
            "sortOrder": 1,
            "targetUrl": "https://example.com",
            "displayImage": {
                "displayUrl": "https://example.com/banner.jpg"
            },
            "mobileImage": {
                "displayUrl": "https://example.com/banner_mobile.jpg"
            },
            "desktopImage": {
                "displayUrl": "https://example.com/banner_desktop.jpg"
            }
        }
        """

        let result = try decoder.decode(HomeBannerDTO.self, from: json.data(using: .utf8)!)

        XCTAssertEqual(result.id, "banner-1")
        XCTAssertEqual(result.sortOrder, 1)
        XCTAssertEqual(result.targetUrl, "https://example.com")
        XCTAssertNotNil(result.displayImage)
        XCTAssertNotNil(result.mobileImage)
        XCTAssertNotNil(result.desktopImage)
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
        XCTAssertEqual(result.contentBlocks.count, 0)
        XCTAssertEqual(result.relatedArticles.count, 0)
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

    // MARK: - ImagePreviewUrl Tests

    func testImagePreviewUrlListPriority() throws {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: "https://example.com/original.jpg",
            displayUrl: "https://example.com/display.jpg",
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )

        // 列表优先级：displayUrl -> thumbnailUrl -> originalUrl -> sourceUrl
        let listUrl = ImagePreviewUrl.listUrl(from: asset)
        XCTAssertEqual(listUrl, "https://example.com/display.jpg")
    }

    func testImagePreviewUrlPreviewPriority() throws {
        let asset = MediaAssetDTO(
            sourceUrl: "https://example.com/source.jpg",
            originalUrl: "https://example.com/original.jpg",
            displayUrl: "https://example.com/display.jpg",
            thumbnailUrl: "https://example.com/thumb.jpg",
            altText: nil
        )

        // 预览优先级：originalUrl -> displayUrl -> sourceUrl -> thumbnailUrl
        let previewUrl = ImagePreviewUrl.previewUrl(from: asset)
        XCTAssertEqual(previewUrl, "https://example.com/original.jpg")
    }

    func testImagePreviewUrlCollect() throws {
        let coverImage = MediaAssetDTO(
            sourceUrl: nil,
            originalUrl: "https://example.com/cover.jpg",
            displayUrl: nil,
            thumbnailUrl: nil,
            altText: nil
        )

        let gallery = [
            MediaAssetDTO(sourceUrl: nil, originalUrl: "https://example.com/gallery1.jpg", displayUrl: nil, thumbnailUrl: nil, altText: nil),
            MediaAssetDTO(sourceUrl: nil, originalUrl: "https://example.com/gallery2.jpg", displayUrl: nil, thumbnailUrl: nil, altText: nil)
        ]

        let contentBlocks = [
            ArticleContentBlockDTO(type: .image, text: nil, image: MediaAssetDTO(sourceUrl: nil, originalUrl: "https://example.com/content.jpg", displayUrl: nil, thumbnailUrl: nil, altText: nil)),
            ArticleContentBlockDTO(type: .text, text: "正文", image: nil)
        ]

        let urls = ImagePreviewUrl.collect(coverImage: coverImage, gallery: gallery, contentBlocks: contentBlocks)

        XCTAssertEqual(urls.count, 4) // cover + 2 gallery + 1 content image
        XCTAssertTrue(urls.contains("https://example.com/cover.jpg"))
        XCTAssertTrue(urls.contains("https://example.com/gallery1.jpg"))
        XCTAssertTrue(urls.contains("https://example.com/gallery2.jpg"))
        XCTAssertTrue(urls.contains("https://example.com/content.jpg"))
    }

    func testImagePreviewUrlNilAsset() throws {
        let listUrl = ImagePreviewUrl.listUrl(from: nil)
        XCTAssertNil(listUrl)

        let previewUrl = ImagePreviewUrl.previewUrl(from: nil)
        XCTAssertNil(previewUrl)
    }
}
