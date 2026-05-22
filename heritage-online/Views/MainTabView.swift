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
                    ArticlesListView(onSettings: { showSettings = true })
                        .tabItem {
                            Label(HomeTab.articles.label, systemImage: HomeTab.articles.icon)
                        }
                        .tag(HomeTab.articles)

                    DirectoryListView()
                        .tabItem {
                            Label(HomeTab.directory.label, systemImage: HomeTab.directory.icon)
                        }
                        .tag(HomeTab.directory)

                    InheritorsListView()
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

// MARK: - Articles Navigation

enum ArticleNavigationDestination: Hashable {
    case articleDetail(id: String?, sourceId: String?, sourceUrl: String?, category: ArticleCategory)
}

struct ArticlesListView: View {
    let onSettings: () -> Void
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ArticlesScreen(navigationPath: $navigationPath, onSettings: onSettings)
                .navigationTitle(String(localized: "nav_articles"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { onSettings() } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    #else
                    ToolbarItem(placement: .automatic) {
                        Button { onSettings() } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    #endif
                }
                .navigationDestination(for: ArticleNavigationDestination.self) { dest in
                    switch dest {
                    case .articleDetail(let id, let sourceId, let sourceUrl, let category):
                        ArticleDetailScreen(
                            articleId: id,
                            sourceId: sourceId,
                            sourceUrl: sourceUrl,
                            category: category,
                            navigationPath: $navigationPath
                        )
                    }
                }
        }
    }
}

// MARK: - Directory Navigation

enum DirectoryNavigationDestination: Hashable {
    case directoryDetail(id: String?, sourceId: String?, kind: DirectoryItemKind)
}

struct DirectoryListView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            DirectoryScreen(navigationPath: $navigationPath)
                .navigationTitle(String(localized: "nav_directory"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationDestination(for: DirectoryNavigationDestination.self) { dest in
                    switch dest {
                    case .directoryDetail(let id, let sourceId, let kind):
                        DirectoryDetailScreen(
                            itemId: id,
                            sourceId: sourceId,
                            kind: kind,
                            navigationPath: $navigationPath
                        )
                    }
                }
        }
    }
}

// MARK: - Inheritors Navigation

enum InheritorNavigationDestination: Hashable {
    case inheritorDetail(id: String?, sourceId: String?)
    case directoryDetail(id: String?, sourceId: String?, kind: DirectoryItemKind)
}

struct InheritorsListView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            InheritorsScreen(navigationPath: $navigationPath)
                .navigationTitle(String(localized: "nav_inheritors"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationDestination(for: InheritorNavigationDestination.self) { dest in
                    switch dest {
                    case .inheritorDetail(let id, let sourceId):
                        InheritorDetailScreen(
                            inheritorId: id,
                            sourceId: sourceId,
                            navigationPath: $navigationPath
                        )
                    case .directoryDetail(let id, let sourceId, let kind):
                        DirectoryDetailScreen(
                            itemId: id,
                            sourceId: sourceId,
                            kind: kind,
                            navigationPath: $navigationPath
                        )
                    }
                }
        }
    }
}
