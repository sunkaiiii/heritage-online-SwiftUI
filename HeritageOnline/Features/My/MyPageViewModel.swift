import SwiftUI
import Foundation

/// 我的页 Tab 类型
enum MyPageTab: String, CaseIterable {
    case favorites
    case recentlyViewed

    var localizationKey: LocalizedStringKey {
        switch self {
        case .favorites: return "my.favorites"
        case .recentlyViewed: return "my.recentlyViewed"
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

    private let repository: SavedContentRepository

    init(repository: SavedContentRepository = DefaultSavedContentRepository.shared) {
        self.repository = repository
    }

    func load() async {
        favorites = await repository.favorites()
        recentlyViewed = await repository.recentlyViewed()
    }

    func unfavorite(_ item: SavedContent) async {
        await repository.removeFavorite(item.contentKey)
        await load()
    }

    func removeRecent(_ item: SavedContent) async {
        await repository.removeRecent(item.contentKey)
        await load()
    }

    func clearRecent() async {
        await repository.clearRecent()
        await load()
    }
}
