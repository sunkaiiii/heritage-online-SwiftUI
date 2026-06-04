import XCTest
@testable import HeritageOnline

/// MyPageViewModel 单元测试
/// 覆盖：加载、取消收藏、删除浏览、清空浏览
@preconcurrency @MainActor
final class MyPageViewModelTests: XCTestCase {
    var savedRepository: MockSavedContentRepository!
    var readingPathRepository: MockReadingPathRepository!
    var viewModel: MyPageViewModel!

    override func setUp() {
        super.setUp()
        savedRepository = MockSavedContentRepository()
        readingPathRepository = MockReadingPathRepository()
        viewModel = MyPageViewModel(
            savedRepository: savedRepository,
            readingPathRepository: readingPathRepository
        )
    }

    override func tearDown() {
        savedRepository = nil
        readingPathRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 加载

    func testLoadEmpty() async {
        // When
        await viewModel.load()

        // Then
        XCTAssertTrue(viewModel.favorites.isEmpty)
        XCTAssertTrue(viewModel.recentlyViewed.isEmpty)
        XCTAssertTrue(viewModel.readingPaths.isEmpty)
    }

    func testLoadWithFavorites() async {
        // Given - 先收藏
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await savedRepository.toggleFavorite(snapshot)

        // When
        await viewModel.load()

        // Then
        XCTAssertEqual(viewModel.favorites.count, 1)
        XCTAssertEqual(viewModel.favorites.first?.title, "测试文章")
    }

    func testLoadWithRecentlyViewed() async {
        // Given - 先记录浏览
        let snapshot = createSnapshot(id: "test1", title: "测试文章", type: .article)
        await savedRepository.recordViewed(snapshot)

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
        await savedRepository.toggleFavorite(snapshot)
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
        await savedRepository.recordViewed(snapshot)
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
        await savedRepository.recordViewed(snapshot1)
        await savedRepository.recordViewed(snapshot2)
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
        await savedRepository.toggleFavorite(snapshot)
        await savedRepository.recordViewed(snapshot)
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

    // MARK: - 阅读路径

    func testClearReadingPath() async {
        // Given - 添加阅读路径
        let event = ReadingPathEvent(
            id: ReadingPathEvent.computeId(fromType: .article, fromId: "a1", toType: .directoryItem, toId: "d1", source: .list),
            fromType: .article,
            fromId: "a1",
            fromTitle: "From",
            toType: .directoryItem,
            toId: "d1",
            toTitle: "To",
            source: .list,
            toCategory: nil,
            toKind: nil,
            toSourceId: nil,
            toSourceUrl: nil,
            toSubtitle: nil,
            toImageUrl: nil,
            createdAt: Date()
        )
        await readingPathRepository.record(event)
        await viewModel.load()
        XCTAssertEqual(viewModel.readingPaths.count, 1)

        // When
        await viewModel.clearReadingPath()

        // Then
        XCTAssertTrue(viewModel.readingPaths.isEmpty)
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
}

// MARK: - Mock SavedContentRepository

/// 内存版本的 SavedContentRepository，避免污染 UserDefaults
final class MockSavedContentRepository: SavedContentRepository, @unchecked Sendable {
    private var items: [SavedContent] = []

    func favorites() async -> [SavedContent] {
        items.filter { $0.isFavorite }.sorted { ($0.favoritedAt ?? .distantPast) > ($1.favoritedAt ?? .distantPast) }
    }

    func recentlyViewed() async -> [SavedContent] {
        items.filter { $0.lastViewedAt != nil }.sorted { ($0.lastViewedAt ?? .distantPast) > ($1.lastViewedAt ?? .distantPast) }
    }

    func toggleFavorite(_ snapshot: SavedContent) async {
        let key = snapshot.contentKey
        if let index = items.firstIndex(where: { $0.contentKey == key }) {
            if items[index].isFavorite {
                items[index].isFavorite = false
                items[index].favoritedAt = nil
            } else {
                items[index].isFavorite = true
                items[index].favoritedAt = Date()
            }
        } else {
            var new = snapshot
            new.isFavorite = true
            new.favoritedAt = Date()
            items.append(new)
        }
    }

    func recordViewed(_ snapshot: SavedContent) async {
        let key = snapshot.contentKey
        if let index = items.firstIndex(where: { $0.contentKey == key }) {
            items[index].lastViewedAt = Date()
            items[index].title = snapshot.title
            items[index].subtitle = snapshot.subtitle
            items[index].summary = snapshot.summary
            items[index].imageUrl = snapshot.imageUrl
        } else {
            var new = snapshot
            new.lastViewedAt = Date()
            items.append(new)
        }
    }

    func removeFavorite(_ contentKey: String) async {
        if let index = items.firstIndex(where: { $0.contentKey == contentKey }) {
            items[index].isFavorite = false
            items[index].favoritedAt = nil
            if items[index].lastViewedAt == nil {
                items.remove(at: index)
            }
        }
    }

    func removeRecent(_ contentKey: String) async {
        if let index = items.firstIndex(where: { $0.contentKey == contentKey }) {
            items[index].lastViewedAt = nil
            if !items[index].isFavorite {
                items.remove(at: index)
            }
        }
    }

    func clearRecent() async {
        for i in items.indices {
            items[i].lastViewedAt = nil
        }
        items.removeAll { !$0.isFavorite && $0.lastViewedAt == nil }
    }

    func isFavorite(_ contentKey: String) async -> Bool {
        items.first(where: { $0.contentKey == contentKey })?.isFavorite ?? false
    }
}

// MARK: - Mock ReadingPathRepository

/// 内存版本的 ReadingPathRepository，避免污染 UserDefaults
final class MockReadingPathRepository: ReadingPathRepository, @unchecked Sendable {
    private var events: [ReadingPathEvent] = []
    private let maxEvents = 50

    func events() async -> [ReadingPathEvent] {
        events
    }

    func record(_ event: ReadingPathEvent) async {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].createdAt = Date()
        } else {
            events.insert(event, at: 0)
        }
        if events.count > maxEvents {
            events = Array(events.prefix(maxEvents))
        }
    }

    func clearAll() async {
        events.removeAll()
    }
}
