import XCTest
@testable import HeritageOnline

/// 我的页导航映射单元测试
/// 覆盖：SavedContent -> tab + detail lookup、ReadingPathEvent -> tab + detail lookup
final class MyPageNavigationMappingTests: XCTestCase {

    // MARK: - SavedContent -> Tab

    func testArticleSavedContentMapsToArticlesTab() {
        let content = createSavedContent(type: .article, targetId: "a1")
        XCTAssertEqual(content.targetTab, .articles)
    }

    func testDirectorySavedContentMapsToDirectoryTab() {
        let content = createSavedContent(type: .directoryItem, targetId: "d1")
        XCTAssertEqual(content.targetTab, .directory)
    }

    func testInheritorSavedContentMapsToInheritorsTab() {
        let content = createSavedContent(type: .inheritor, targetId: "i1")
        XCTAssertEqual(content.targetTab, .inheritors)
    }

    // MARK: - SavedContent -> Detail Lookup

    func testArticleSavedContentHasCorrectTargetId() {
        let content = createSavedContent(type: .article, targetId: "a1", targetSourceId: "src-a1")
        XCTAssertEqual(content.targetId, "a1")
        XCTAssertEqual(content.targetSourceId, "src-a1")
    }

    func testDirectorySavedContentHasCorrectKind() {
        let content = createSavedContent(
            type: .directoryItem,
            targetId: "d1",
            targetSourceId: nil,
            targetKind: "nationalProject"
        )
        XCTAssertEqual(content.targetKind, "nationalProject")
    }

    func testInheritorSavedContentHasCorrectFields() {
        let content = createSavedContent(type: .inheritor, targetId: "i1", targetSourceId: "inh-src")
        XCTAssertEqual(content.targetId, "i1")
        XCTAssertEqual(content.targetSourceId, "inh-src")
    }

    // MARK: - ReadingPathEvent -> Tab

    func testArticleReadingPathMapsToArticlesTab() {
        let event = createReadingPathEvent(toType: .article, toId: "a1")
        XCTAssertEqual(event.targetTab, .articles)
    }

    func testDirectoryReadingPathMapsToDirectoryTab() {
        let event = createReadingPathEvent(toType: .directoryItem, toId: "d1")
        XCTAssertEqual(event.targetTab, .directory)
    }

    func testInheritorReadingPathMapsToInheritorsTab() {
        let event = createReadingPathEvent(toType: .inheritor, toId: "i1")
        XCTAssertEqual(event.targetTab, .inheritors)
    }

    // MARK: - ReadingPathEvent -> Detail Lookup

    func testReadingPathEventHasCorrectToFields() {
        let event = createReadingPathEvent(
            toType: .directoryItem,
            toId: "d1",
            toSourceId: "dir-src",
            toCategory: "传统音乐",
            toKind: "nationalProject"
        )
        XCTAssertEqual(event.toId, "d1")
        XCTAssertEqual(event.toSourceId, "dir-src")
        XCTAssertEqual(event.toCategory, "传统音乐")
        XCTAssertEqual(event.toKind, "nationalProject")
    }

    func testReadingPathEventSourceIdPriority() {
        // When toSourceId is set and toId is also set, both should be preserved
        let event = createReadingPathEvent(
            toType: .article,
            toId: "a1",
            toSourceId: "src-a1",
            toSourceUrl: "https://example.com"
        )
        XCTAssertEqual(event.toId, "a1")
        XCTAssertEqual(event.toSourceId, "src-a1")
        XCTAssertEqual(event.toSourceUrl, "https://example.com")
    }

    // MARK: - ContentView buildRoute

    func testBuildRouteFromSavedContentArticle() {
        let content = createSavedContent(
            type: .article,
            targetId: "a1",
            targetSourceId: "src-a1",
            targetSourceUrl: "https://example.com",
            targetCategory: "news"
        )

        // Simulate what ContentView.buildRoute does
        let category = ArticleCategory(rawValue: content.targetCategory ?? "") ?? .news
        let route = AppRoute.article(
            articleId: content.targetId,
            sourceId: content.targetSourceId,
            sourceUrl: content.targetSourceUrl,
            category: category
        )

        // Verify route is constructible
        switch route {
        case .article(let articleId, let sourceId, let sourceUrl, let cat):
            XCTAssertEqual(articleId, "a1")
            XCTAssertEqual(sourceId, "src-a1")
            XCTAssertEqual(sourceUrl, "https://example.com")
            XCTAssertEqual(cat, .news)
        default:
            XCTFail("Expected article route")
        }
    }

    func testBuildRouteFromSavedContentDirectory() {
        let content = createSavedContent(
            type: .directoryItem,
            targetId: "d1",
            targetSourceId: "dir-src",
            targetKind: "culturalEcoZone"
        )

        let kind = DirectoryItemKind(rawValue: content.targetKind ?? "") ?? .nationalProject
        let route = AppRoute.directory(
            itemId: content.targetId,
            sourceId: content.targetSourceId,
            kind: kind
        )

        switch route {
        case .directory(let itemId, let sourceId, let k):
            XCTAssertEqual(itemId, "d1")
            XCTAssertEqual(sourceId, "dir-src")
            XCTAssertEqual(k, .culturalEcoZone)
        default:
            XCTFail("Expected directory route")
        }
    }

    func testBuildRouteFromReadingPathEvent() {
        let event = createReadingPathEvent(
            toType: .inheritor,
            toId: "i1",
            toSourceId: "inh-src"
        )

        let route = AppRoute.inheritor(
            inheritorId: event.toId,
            sourceId: event.toSourceId
        )

        switch route {
        case .inheritor(let inheritorId, let sourceId):
            XCTAssertEqual(inheritorId, "i1")
            XCTAssertEqual(sourceId, "inh-src")
        default:
            XCTFail("Expected inheritor route")
        }
    }

    // MARK: - Helpers

    private func createSavedContent(
        type: SavedContentType,
        targetId: String?,
        targetSourceId: String? = nil,
        targetSourceUrl: String? = nil,
        targetCategory: String? = nil,
        targetKind: String? = nil
    ) -> SavedContent {
        SavedContent(
            contentKey: "id:\(targetId ?? "unknown")",
            contentType: type,
            title: "Test",
            subtitle: nil,
            summary: nil,
            imageUrl: nil,
            category: targetCategory,
            region: nil,
            targetId: targetId,
            targetSourceId: targetSourceId,
            targetSourceUrl: targetSourceUrl,
            targetCategory: targetCategory,
            targetKind: targetKind,
            isFavorite: false,
            favoritedAt: nil,
            lastViewedAt: nil
        )
    }

    private func createReadingPathEvent(
        toType: SavedContentType,
        toId: String,
        toSourceId: String? = nil,
        toSourceUrl: String? = nil,
        toCategory: String? = nil,
        toKind: String? = nil
    ) -> ReadingPathEvent {
        ReadingPathEvent(
            id: ReadingPathEvent.computeId(
                fromType: .article, fromId: "from1",
                toType: toType, toId: toId, source: .related
            ),
            fromType: .article,
            fromId: "from1",
            fromTitle: "From",
            toType: toType,
            toId: toId,
            toTitle: "To",
            source: .related,
            toCategory: toCategory,
            toKind: toKind,
            toSourceId: toSourceId,
            toSourceUrl: toSourceUrl,
            toSubtitle: nil,
            toImageUrl: nil,
            createdAt: Date()
        )
    }
}
