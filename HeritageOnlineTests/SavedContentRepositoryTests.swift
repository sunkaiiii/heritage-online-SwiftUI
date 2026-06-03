import XCTest
@testable import HeritageOnline

/// SavedContentRepository 单元测试
/// 覆盖：收藏 toggle、最近浏览记录、删除、清空、重复打开
@MainActor
final class SavedContentRepositoryTests: XCTestCase {
    var repository: DefaultSavedContentRepository!

    override func setUp() {
        super.setUp()
        repository = DefaultSavedContentRepository.shared
        // 清理 UserDefaults 中的测试数据
        clearTestData()
    }

    override func tearDown() {
        clearTestData()
        super.tearDown()
    }

    // MARK: - 收藏

    func testToggleFavoriteAddsNewFavorite() async {
        // Given
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)

        // When - 首次收藏
        await repository.toggleFavorite(snapshot)

        // Then
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.title, "测试文章")
        XCTAssertTrue(favorites.first?.isFavorite ?? false)
        XCTAssertNotNil(favorites.first?.favoritedAt)
    }

    func testToggleFavoriteRemovesExistingFavorite() async {
        // Given - 先收藏
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)
        var favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 1)

        // When - 再次 toggle 取消收藏
        await repository.toggleFavorite(snapshot)

        // Then
        favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 0)
    }

    func testFavoritePreservesRecentlyViewed() async {
        // Given - 先记录浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.recordViewed(snapshot)
        var recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 1)

        // When - 再收藏
        await repository.toggleFavorite(snapshot)

        // Then - 浏览记录保留
        recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 1)
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 1)
    }

    func testUnfavoritePreservesRecentlyViewed() async {
        // Given - 收藏 + 浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)
        await repository.recordViewed(snapshot)

        // When - 取消收藏
        await repository.toggleFavorite(snapshot)

        // Then - 浏览记录保留，收藏消失
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 0)
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 1)
    }

    func testRemoveFavoriteClearsRecordIfNoRecentView() async {
        // Given - 只收藏不浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)

        // When - 移除收藏
        await repository.removeFavorite(snapshot.contentKey)

        // Then - 整条记录被移除
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 0)
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 0)
    }

    // MARK: - 最近浏览

    func testRecordViewedAddsNewRecord() async {
        // Given
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)

        // When
        await repository.recordViewed(snapshot)

        // Then
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 1)
        XCTAssertEqual(recent.first?.title, "测试文章")
        XCTAssertNotNil(recent.first?.lastViewedAt)
    }

    func testRecordViewedUpdatesExistingRecord() async {
        // Given - 先记录一次
        let snapshot1 = createSnapshot(id: "test1", title: "原始标题", type: .article)
        await repository.recordViewed(snapshot1)

        // When - 再次记录（更新标题）
        let snapshot2 = createSnapshot(id: "test1", title: "更新标题", type: .article)
        await repository.recordViewed(snapshot2)

        // Then - 只有一条记录，标题已更新
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 1)
        XCTAssertEqual(recent.first?.title, "更新标题")
    }

    func testRecordViewedDoesNotDuplicate() async {
        // Given
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)

        // When - 多次记录
        await repository.recordViewed(snapshot)
        await repository.recordViewed(snapshot)
        await repository.recordViewed(snapshot)

        // Then - 只有一条记录
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 1)
    }

    func testRecentlyViewedSortedByTimeDescending() async {
        // Given - 记录多条
        let snapshot1 = createSnapshot(id: "test1", title: "文章1", type: .article)
        let snapshot2 = createSnapshot(id: "test2", title: "文章2", type: .article)
        let snapshot3 = createSnapshot(id: "test3", title: "文章3", type: .article)

        await repository.recordViewed(snapshot1)
        await repository.recordViewed(snapshot2)
        await repository.recordViewed(snapshot3)

        // Then - 按时间倒序
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 3)
        XCTAssertEqual(recent[0].title, "文章3")
        XCTAssertEqual(recent[1].title, "文章2")
        XCTAssertEqual(recent[2].title, "文章1")
    }

    func testRemoveRecent() async {
        // Given
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.recordViewed(snapshot)

        // When
        await repository.removeRecent(snapshot.contentKey)

        // Then
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 0)
    }

    func testRemoveRecentPreservesFavorite() async {
        // Given - 收藏 + 浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)
        await repository.recordViewed(snapshot)

        // When - 删除浏览记录
        await repository.removeRecent(snapshot.contentKey)

        // Then - 收藏保留
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 1)
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 0)
    }

    func testClearRecent() async {
        // Given - 多条浏览记录
        let snapshot1 = createSnapshot(id: "test1", title: "文章1", type: .article)
        let snapshot2 = createSnapshot(id: "test2", title: "文章2", type: .article)
        await repository.recordViewed(snapshot1)
        await repository.recordViewed(snapshot2)

        // When
        await repository.clearRecent()

        // Then
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 0)
    }

    func testClearRecentPreservesFavorites() async {
        // Given - 收藏 + 浏览
        let snapshot1 = createSnapshot(id: "test1", title: "文章1", type: .article)
        let snapshot2 = createSnapshot(id: "test2", title: "文章2", type: .article)
        await repository.toggleFavorite(snapshot1)
        await repository.recordViewed(snapshot1)
        await repository.recordViewed(snapshot2)

        // When - 清空浏览
        await repository.clearRecent()

        // Then - 收藏保留，浏览清空
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 1)
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 0)
    }

    // MARK: - 查询

    func testIsFavorite() async {
        // Given
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)

        // When/Then - 未收藏
        let isFav1 = await repository.isFavorite(snapshot.contentKey)
        XCTAssertFalse(isFav1)

        // When - 收藏后
        await repository.toggleFavorite(snapshot)
        let isFav2 = await repository.isFavorite(snapshot.contentKey)
        XCTAssertTrue(isFav2)
    }

    // MARK: - 多类型

    func testMultipleContentTypes() async {
        // Given
        let article = createSnapshot(id: "a1", title: "文章", type: .article)
        let directory = createSnapshot(id: "d1", title: "名录", type: .directoryItem)
        let inheritor = createSnapshot(id: "i1", title: "传承人", type: .inheritor)

        // When
        await repository.toggleFavorite(article)
        await repository.recordViewed(directory)
        await repository.toggleFavorite(inheritor)

        // Then
        let favorites = await repository.favorites()
        XCTAssertEqual(favorites.count, 2)
        let recent = await repository.recentlyViewed()
        XCTAssertEqual(recent.count, 2)
    }

    // MARK: - 重启持久化

    func testFavoritesPersistAcrossInstances() async {
        // Given
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)

        // When - 新建实例（模拟重启）
        let newRepository = DefaultSavedContentRepository.shared

        // Then - 数据保留
        let favorites = await newRepository.favorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.title, "测试文章")
    }

    // MARK: - Helpers

    private func createSnapshot(id: String, title: String, type: SavedContentType) -> SavedContent {
        SavedContent(
            contentKey: "id:\(id)",
            contentType: type,
            title: title,
            subtitle: nil,
            summary: nil,
            imageUrl: nil,
            category: nil,
            region: nil,
            targetId: id,
            targetSourceId: nil,
            targetSourceUrl: nil,
            targetCategory: nil,
            targetKind: nil,
            isFavorite: false,
            favoritedAt: nil,
            lastViewedAt: nil
        )
    }

    private func clearTestData() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "saved_content_favorites")
    }
}
