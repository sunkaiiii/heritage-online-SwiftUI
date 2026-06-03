import SwiftUI
import Foundation

/// 我的页 Tab 类型
enum MyPageTab: String, CaseIterable {
    case favorites
    case recentlyViewed
    case readingPath

    var localizationKey: LocalizedStringKey {
        switch self {
        case .favorites: return "my.favorites"
        case .recentlyViewed: return "my.recentlyViewed"
        case .readingPath: return "my.readingPath"
        }
    }
}

/// 我的页 ViewModel
/// 对齐 Android MyPageViewModel
@Observable
final class MyPageViewModel {
    var selectedTab: MyPageTab = .favorites
    var favorites: [SavedContent] = []
    var recentlyViewed: [SavedContent] = []
    var readingPaths: [ReadingPathEvent] = []

    private let savedRepository: SavedContentRepository
    private let readingPathRepository: ReadingPathRepository

    init(
        savedRepository: SavedContentRepository = DefaultSavedContentRepository.shared,
        readingPathRepository: ReadingPathRepository = DefaultReadingPathRepository.shared
    ) {
        self.savedRepository = savedRepository
        self.readingPathRepository = readingPathRepository
    }

    func load() async {
        favorites = await savedRepository.favorites()
        recentlyViewed = await savedRepository.recentlyViewed()
        readingPaths = await readingPathRepository.events()
    }

    func unfavorite(_ item: SavedContent) async {
        await savedRepository.removeFavorite(item.contentKey)
        await load()
    }

    func removeRecent(_ item: SavedContent) async {
        await savedRepository.removeRecent(item.contentKey)
        await load()
    }

    func clearRecent() async {
        await savedRepository.clearRecent()
        await load()
    }

    func clearReadingPath() async {
        await readingPathRepository.clearAll()
        await load()
    }
}
