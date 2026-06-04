import XCTest
@testable import HeritageOnline

/// SavedContent 模型单元测试
/// 覆盖：computeKey、fromArticle、fromDirectoryItem、fromInheritor
final class SavedContentTests: XCTestCase {

    // MARK: - computeKey

    func testComputeKeyPrefersTargetId() {
        let key = SavedContent.computeKey(
            targetId: "abc123",
            targetSourceUrl: "https://example.com",
            targetSourceId: "sid123"
        )
        XCTAssertEqual(key, "id:abc123")
    }

    func testComputeKeyFallsBackToSourceUrl() {
        let key = SavedContent.computeKey(
            targetId: nil,
            targetSourceUrl: "https://example.com",
            targetSourceId: "sid123"
        )
        XCTAssertEqual(key, "url:https://example.com")
    }

    func testComputeKeyFallsBackToSourceId() {
        let key = SavedContent.computeKey(
            targetId: nil,
            targetSourceUrl: nil,
            targetSourceId: "sid123"
        )
        XCTAssertEqual(key, "sid:sid123")
    }

    func testComputeKeyGeneratesUnknownWhenAllNil() {
        let key = SavedContent.computeKey(
            targetId: nil,
            targetSourceUrl: nil,
            targetSourceId: nil
        )
        XCTAssertTrue(key.hasPrefix("unknown:"))
    }

    func testComputeKeyIgnoresEmptyStrings() {
        let key = SavedContent.computeKey(
            targetId: "",
            targetSourceUrl: "",
            targetSourceId: ""
        )
        XCTAssertTrue(key.hasPrefix("unknown:"))
    }

    // MARK: - fromArticle

    func testFromArticle() {
        let article = ArticleDetailDTO(
            id: "a1",
            category: "news",
            title: "测试文章",
            summary: "摘要",
            publishedAt: "2024-01-01",
            coverImage: nil,
            sourceUrl: "https://example.com",
            sourceName: "来源",
            author: "作者",
            editor: nil,
            contentBlocks: [],
            relatedArticles: []
        )

        let snapshot = SavedContent.fromArticle(article)

        XCTAssertEqual(snapshot.contentType, .article)
        XCTAssertEqual(snapshot.title, "测试文章")
        XCTAssertEqual(snapshot.targetId, "a1")
        XCTAssertEqual(snapshot.targetSourceUrl, "https://example.com")
        XCTAssertEqual(snapshot.category, "news")
        XCTAssertFalse(snapshot.isFavorite)
        XCTAssertNil(snapshot.lastViewedAt)
    }

    func testFromArticlePreservesSourceId() {
        let article = ArticleDetailDTO(
            id: "a1",
            sourceId: "src-abc",
            category: "news",
            title: "测试文章",
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

        let snapshot = SavedContent.fromArticle(article)

        XCTAssertEqual(snapshot.targetSourceId, "src-abc")
        XCTAssertEqual(snapshot.contentKey, "id:a1")
    }

    // MARK: - fromDirectoryItem

    func testFromDirectoryItem() {
        let item = DirectoryItemDetailDTO(
            id: "d1",
            kind: "nationalProject",
            title: "测试名录",
            summary: "摘要",
            category: "传统音乐",
            region: "北京",
            projectCode: "P001",
            batch: "第一批",
            publishedYear: 2024,
            listType: nil,
            nominationType: nil,
            protectionUnit: nil,
            coverImage: nil,
            sourceUrl: "https://example.com/dir",
            gallery: [],
            contentBlocks: [],
            relatedProjects: [],
            relatedInheritors: [],
            relatedDocuments: []
        )

        let snapshot = SavedContent.fromDirectoryItem(item)

        XCTAssertEqual(snapshot.contentType, .directoryItem)
        XCTAssertEqual(snapshot.title, "测试名录")
        XCTAssertEqual(snapshot.targetId, "d1")
        XCTAssertEqual(snapshot.category, "传统音乐")
        XCTAssertEqual(snapshot.region, "北京")
        XCTAssertEqual(snapshot.targetKind, "nationalProject")
    }

    func testFromDirectoryItemPreservesSourceId() {
        let item = DirectoryItemDetailDTO(
            id: "d1",
            sourceId: "dir-src-001",
            kind: "nationalProject",
            title: "测试名录",
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

        let snapshot = SavedContent.fromDirectoryItem(item)

        XCTAssertEqual(snapshot.targetSourceId, "dir-src-001")
        XCTAssertEqual(snapshot.contentKey, "id:d1")
    }

    // MARK: - fromInheritor

    func testFromInheritor() {
        let inheritor = InheritorDetailDTO(
            id: "i1",
            name: "张三",
            gender: "male",
            birthDateText: "1950年",
            ethnicity: "汉族",
            category: "传统戏剧",
            projectCode: "P002",
            projectName: "京剧",
            region: "北京",
            batch: "第一批",
            description: "简介",
            coverImage: nil,
            sourceUrl: "https://example.com/inh",
            contentBlocks: [],
            relatedProjects: [],
            relatedInheritors: []
        )

        let snapshot = SavedContent.fromInheritor(inheritor)

        XCTAssertEqual(snapshot.contentType, .inheritor)
        XCTAssertEqual(snapshot.title, "张三")
        XCTAssertEqual(snapshot.targetId, "i1")
        XCTAssertEqual(snapshot.subtitle, "京剧")
        XCTAssertEqual(snapshot.category, "传统戏剧")
    }

    func testFromInheritorPreservesSourceId() {
        let inheritor = InheritorDetailDTO(
            id: "i1",
            sourceId: "inh-src-001",
            name: "张三",
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

        let snapshot = SavedContent.fromInheritor(inheritor)

        XCTAssertEqual(snapshot.targetSourceId, "inh-src-001")
        XCTAssertEqual(snapshot.contentKey, "id:i1")
    }

    // MARK: - Identifiable

    func testIdEqualsContentKey() {
        let snapshot = SavedContent(
            contentKey: "test-key",
            contentType: .article,
            title: "标题",
            subtitle: nil,
            summary: nil,
            imageUrl: nil,
            category: nil,
            region: nil,
            targetId: nil,
            targetSourceId: nil,
            targetSourceUrl: nil,
            targetCategory: nil,
            targetKind: nil,
            isFavorite: false,
            favoritedAt: nil,
            lastViewedAt: nil
        )
        XCTAssertEqual(snapshot.id, "test-key")
    }

    // MARK: - Codable

    func testEncodeDecode() throws {
        let original = SavedContent(
            contentKey: "test-key",
            contentType: .article,
            title: "标题",
            subtitle: "副标题",
            summary: "摘要",
            imageUrl: "https://example.com/img.jpg",
            category: "news",
            region: "北京",
            targetId: "a1",
            targetSourceId: "sid1",
            targetSourceUrl: "https://example.com",
            targetCategory: "news",
            targetKind: nil,
            isFavorite: true,
            favoritedAt: Date(timeIntervalSince1970: 1000),
            lastViewedAt: Date(timeIntervalSince1970: 2000)
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SavedContent.self, from: data)

        XCTAssertEqual(decoded.contentKey, original.contentKey)
        XCTAssertEqual(decoded.contentType, original.contentType)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.isFavorite, original.isFavorite)
    }
}
