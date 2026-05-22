import SwiftUI

enum HomeTab: String, CaseIterable {
    case articles
    case directory
    case inheritors

    var labelKey: String {
        switch self {
        case .articles: return "nav_articles"
        case .directory: return "nav_directory"
        case .inheritors: return "nav_inheritors"
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
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @State private var selectedTab: HomeTab = .articles
    @State private var showSettings = false
    @State private var showMyPage = false
    @AppStorage("theme_mode") private var themeMode: String = AppThemeMode.system.rawValue
    @AppStorage("language_mode") private var languageMode: String = AppLanguageMode.system.rawValue

    var body: some View {
        ZStack {
            if showMyPage {
                MyPage(onBack: { showMyPage = false })
            } else if showSettings {
                SettingsScreen(
                    themeMode: Binding(
                        get: { AppThemeMode(rawValue: themeMode) ?? .system },
                        set: { themeMode = $0.rawValue }
                    ),
                    languageMode: Binding(
                        get: { AppLanguageMode(rawValue: languageMode) ?? .system },
                        set: { languageMode = $0.rawValue }
                    ),
                    onBack: { showSettings = false },
                    onMyPageClick: { showMyPage = true }
                )
            } else {
                TabView(selection: $selectedTab) {
                    ArticlesListView(onSettings: { showSettings = true })
                        .tabItem {
                            Label(loc.localized(HomeTab.articles.labelKey), systemImage: HomeTab.articles.icon)
                        }
                        .tag(HomeTab.articles)

                    DirectoryListView()
                        .tabItem {
                            Label(loc.localized(HomeTab.directory.labelKey), systemImage: HomeTab.directory.icon)
                        }
                        .tag(HomeTab.directory)

                    InheritorsListView()
                        .tabItem {
                            Label(loc.localized(HomeTab.inheritors.labelKey), systemImage: HomeTab.inheritors.icon)
                        }
                        .tag(HomeTab.inheritors)
                }
                .tint(theme.primary)
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
                .navigationTitle("nav_articles")
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
                .navigationTitle("nav_directory")
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
                .navigationTitle("nav_inheritors")
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
