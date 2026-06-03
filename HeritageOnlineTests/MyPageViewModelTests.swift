import XCTest
@testable import HeritageOnline

/// MyPageViewModel 单元测试
/// 覆盖：加载、取消收藏、删除浏览、清空浏览
@MainActor
final class MyPageViewModelTests: XCTestCase {
    var repository: DefaultSavedContentRepository!
    var viewModel: MyPageViewModel!

    override func setUp() {
        super.setUp()
        repository = DefaultSavedContentRepository.shared
        clearTestData()
        viewModel = MyPageViewModel(repository: repository)
    }

    override func tearDown() {
        clearTestData()
        super.tearDown()
    }

    // MARK: - 加载

    func testLoadEmpty() async {
        // When
        await viewModel.load()

        // Then
        XCTAssertTrue(viewModel.favorites.isEmpty)
        XCTAssertTrue(viewModel.recentlyViewed.isEmpty)
    }

    func testLoadWithFavorites() async {
        // Given - 先收藏
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)

        // When
        await viewModel.load()

        // Then
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertEqual(viewModel.favorites.first?.title, "测试文章")
    }

    func testLoadWithRecentlyViewed() async {
        // Given - 先记录浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.recordViewed(snapshot)

        // When
        await viewModel.load()

        // Then
        XCTAssertEqual(viewModel.recentlyViewed.count, 1)
        XCTAssertEqual(viewModel.recentlyViewed.first?.title, "测试文章")
    }

    // MARK: - 取消收藏

    func testUnfavoriteRemovesFromFavorites() async {
        // Given - 先收藏
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)
        await viewModel.load()
        XCTAssertEqual(viewModel.favorites.count, 1)

        // When - 取消收藏
        await viewModel.unfavorite(snapshot)

        // Then
        XCTAssertTrue(viewModel.favorites.isEmpty)
    }

    // MARK: - 删除浏览记录

    func testRemoveRecentRemovesFromList() async {
        // Given - 先记录浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.recordViewed(snapshot)
        await viewModel.load()
        XCTAssertEqual(viewModel.recentlyViewed.count, 1)

        // When - 删除
        await viewModel.removeRecent(snapshot)

        // Then
        XCTAssertTrue(viewModel.recentlyViewed.isEmpty)
    }

    // MARK: - 清空浏览

    func testClearRecentRemovesAll() async {
        // Given - 多条浏览记录
        let snapshot1 = createSnapshot(id: "test1", title: "文章1", type: .article)
        let snapshot2 = createSnapshot(id: "test2", title: "文章2", type: .article)
        await repository.recordViewed(snapshot1)
        await repository.recordViewed(snapshot2)
        await viewModel.load()
        XCTAssertEqual(viewModel.recentlyViewed.count, 2)

        // When - 清空
        await viewModel.clearRecent()

        // Then
        XCTAssertTrue(viewModel.recentlyViewed.isEmpty)
    }

    func testClearRecentPreservesFavorites() async {
        // Given - 收藏 + 浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await repository.toggleFavorite(snapshot)
        await repository.recordViewed(snapshot)
        await viewModel.load()
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertEqual(viewModel.recentlyViewed.count, 1)

        // When - 清空浏览
        await viewModel.clearRecent()

        // Then - 收藏保留
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertTrue(viewModel.recentlyViewed.isEmpty)
    }

    // MARK: - Tab 切换

    func testDefaultTabIsFavorites() {
        XCTAssertEqual(viewModel.selectedTab, .favorites)
    }

    func testSwitchTab() {
        viewModel.selectedTab = .recentlyViewed
        XCTAssertEqual(viewModel.selectedTab, .recentlyViewed)
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
