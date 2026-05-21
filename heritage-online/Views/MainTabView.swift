import SwiftUI

enum HomeTab: String, CaseIterable {
    case articles
    case directory
    case inheritors

    var label: String {
        switch self {
        case .articles: return String(localized: "nav_articles")
        case .directory: return String(localized: "nav_directory")
        case .inheritors: return String(localized: "nav_inheritors")
        }
    }

    var icon: String {
        switch self {
        case .articles: return "newspaper"
        case .directory: return "books.vertical"
        case .inheritors: return "person.3"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: HomeTab = .articles
    @State private var showSettings = false
    @State private var themeMode: AppThemeMode = .system
    @State private var languageMode: AppLanguageMode = .system

    var body: some View {
        ZStack {
            if showSettings {
                SettingsScreen(
                    themeMode: $themeMode,
                    languageMode: $languageMode,
                    onBack: { showSettings = false }
                )
            } else {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        ArticlesListView()
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button {
                                        showSettings = true
                                    } label: {
                                        Image(systemName: "gearshape")
                                    }
                                }
                            }
                    }
                    .tabItem {
                        Label(HomeTab.articles.label, systemImage: HomeTab.articles.icon)
                    }
                    .tag(HomeTab.articles)

                    NavigationStack {
                        DirectoryListView()
                    }
                    .tabItem {
                        Label(HomeTab.directory.label, systemImage: HomeTab.directory.icon)
                    }
                    .tag(HomeTab.directory)

                    NavigationStack {
                        InheritorsListView()
                    }
                    .tabItem {
                        Label(HomeTab.inheritors.label, systemImage: HomeTab.inheritors.icon)
                    }
                    .tag(HomeTab.inheritors)
                }
                .tint(Color(hex: "8F372F"))
            }
        }
    }
}

// MARK: - Wrapper Views for Navigation

struct ArticlesListView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        ArticlesScreen()
            .navigationTitle(String(localized: "nav_articles"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ArticleNavigationDestination.self) { dest in
                switch dest {
                case .articleDetail(let id, let sourceId, let sourceUrl, let category):
                    ArticleDetailScreen(
                        articleId: id,
                        sourceId: sourceId,
                        sourceUrl: sourceUrl,
                        category: category
                    )
                }
            }
    }
}

enum ArticleNavigationDestination: Hashable {
    case articleDetail(id: String?, sourceId: String?, sourceUrl: String?, category: ArticleCategory)
}

struct DirectoryListView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        DirectoryScreen()
            .navigationTitle(String(localized: "nav_directory"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: DirectoryNavigationDestination.self) { dest in
                switch dest {
                case .directoryDetail(let id, let sourceId, let kind):
                    DirectoryDetailScreen(
                        itemId: id,
                        sourceId: sourceId,
                        kind: kind
                    )
                }
            }
    }
}

enum DirectoryNavigationDestination: Hashable {
    case directoryDetail(id: String?, sourceId: String?, kind: DirectoryItemKind)
}

struct InheritorsListView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        InheritorsScreen()
            .navigationTitle(String(localized: "nav_inheritors"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: InheritorNavigationDestination.self) { dest in
                switch dest {
                case .inheritorDetail(let id, let sourceId):
                    InheritorDetailScreen(
                        inheritorId: id,
                        sourceId: sourceId
                    )
                case .directoryDetail(let id, let sourceId, let kind):
                    DirectoryDetailScreen(
                        itemId: id,
                        sourceId: sourceId,
                        kind: kind
                    )
                }
            }
    }
}

enum InheritorNavigationDestination: Hashable {
    case inheritorDetail(id: String?, sourceId: String?)
    case directoryDetail(id: String?, sourceId: String?, kind: DirectoryItemKind)
}
