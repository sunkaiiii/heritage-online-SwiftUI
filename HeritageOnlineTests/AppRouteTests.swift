import XCTest
@testable import HeritageOnline

/// AppRoute 稳定性测试
/// 验证 NavigationLink(value:) 和 NavigationPath 的 Hashable/Identifiable 行为
final class AppRouteTests: XCTestCase {

    // MARK: - ID 稳定性

    func testArticleRouteIdStable() {
        let route1 = AppRoute.article(articleId: "a1", sourceId: nil, sourceUrl: nil, category: .news)
        let route2 = AppRoute.article(articleId: "a1", sourceId: nil, sourceUrl: nil, category: .news)
        XCTAssertEqual(route1.id, route2.id)
    }

    func testDirectoryRouteIdStable() {
        let route1 = AppRoute.directory(itemId: "d1", sourceId: nil, kind: .nationalProject)
        let route2 = AppRoute.directory(itemId: "d1", sourceId: nil, kind: .nationalProject)
        XCTAssertEqual(route1.id, route2.id)
    }

    func testInheritorRouteIdStable() {
        let route1 = AppRoute.inheritor(inheritorId: "i1", sourceId: nil)
        let route2 = AppRoute.inheritor(inheritorId: "i1", sourceId: nil)
        XCTAssertEqual(route1.id, route2.id)
    }

    // MARK: - 不同内容生成不同 ID

    func testDifferentArticleIdsProduceDifferentRouteIds() {
        let route1 = AppRoute.article(articleId: "a1", sourceId: nil, sourceUrl: nil, category: .news)
        let route2 = AppRoute.article(articleId: "a2", sourceId: nil, sourceUrl: nil, category: .news)
        XCTAssertNotEqual(route1.id, route2.id)
    }

    func testDifferentDirectoryIdsProduceDifferentRouteIds() {
        let route1 = AppRoute.directory(itemId: "d1", sourceId: nil, kind: .nationalProject)
        let route2 = AppRoute.directory(itemId: "d2", sourceId: nil, kind: .nationalProject)
        XCTAssertNotEqual(route1.id, route2.id)
    }

    func testDifferentInheritorIdsProduceDifferentRouteIds() {
        let route1 = AppRoute.inheritor(inheritorId: "i1", sourceId: nil)
        let route2 = AppRoute.inheritor(inheritorId: "i2", sourceId: nil)
        XCTAssertNotEqual(route1.id, route2.id)
    }

    // MARK: - 不同类型生成不同 ID

    func testDifferentRouteTypesHaveDifferentIds() {
        let article = AppRoute.article(articleId: "x", sourceId: nil, sourceUrl: nil, category: .news)
        let directory = AppRoute.directory(itemId: "x", sourceId: nil, kind: .nationalProject)
        let inheritor = AppRoute.inheritor(inheritorId: "x", sourceId: nil)

        XCTAssertNotEqual(article.id, directory.id)
        XCTAssertNotEqual(article.id, inheritor.id)
        XCTAssertNotEqual(directory.id, inheritor.id)
    }

    // MARK: - Hashable 一致性

    func testRouteHashableConsistent() {
        let route = AppRoute.article(articleId: "a1", sourceId: "s1", sourceUrl: "https://example.com", category: .news)
        let set: Set<AppRoute> = [route, route, route]
        XCTAssertEqual(set.count, 1)
    }

    func testDifferentRoutesAreNotEqual() {
        let route1 = AppRoute.article(articleId: "a1", sourceId: nil, sourceUrl: nil, category: .news)
        let route2 = AppRoute.article(articleId: "a2", sourceId: nil, sourceUrl: nil, category: .news)
        XCTAssertNotEqual(route1, route2)
    }

    // MARK: - sourceId/sourceUrl 兜底

    func testArticleRouteWithSourceIdOnly() {
        let route = AppRoute.article(articleId: nil, sourceId: "s1", sourceUrl: nil, category: .news)
        XCTAssertFalse(route.id.isEmpty)
        XCTAssertTrue(route.id.contains("s1"))
    }

    func testArticleRouteWithSourceUrlOnly() {
        let route = AppRoute.article(articleId: nil, sourceId: nil, sourceUrl: "https://example.com", category: .news)
        XCTAssertFalse(route.id.isEmpty)
        XCTAssertTrue(route.id.contains("example.com"))
    }
}
