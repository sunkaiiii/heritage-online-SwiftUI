import SwiftUI

enum SidebarItem: String, CaseIterable, Hashable {
    case articles
    case directory
    case inheritors
    case settings

    var labelKey: String {
        switch self {
        case .articles: return "nav_articles"
        case .directory: return "nav_directory"
        case .inheritors: return "nav_inheritors"
        case .settings: return "nav_settings"
        }
    }

    var icon: String {
        switch self {
        case .articles: return "newspaper"
        case .directory: return "books.vertical"
        case .inheritors: return "person.3"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: SidebarItem = .articles
    @State private var articlesPath = NavigationPath()
    @State private var directoryPath = NavigationPath()
    @State private var inheritorsPath = NavigationPath()
    @AppStorage("theme_mode") private var themeMode: String = AppThemeMode.system.rawValue
    @AppStorage("language_mode") private var languageMode: String = AppLanguageMode.system.rawValue

    private var themeBinding: Binding<AppThemeMode> {
        Binding(
            get: { AppThemeMode(rawValue: themeMode) ?? .system },
            set: { themeMode = $0.rawValue }
        )
    }

    private var languageBinding: Binding<AppLanguageMode> {
        Binding(
            get: { AppLanguageMode(rawValue: languageMode) ?? .system },
            set: { languageMode = $0.rawValue }
        )
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            wideLayout
        } else {
            compactLayout
        }
    }

    // MARK: - Wide Layout (macOS, iPad)

    private var wideLayout: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } detail: {
            ZStack {
                ArticlesListView(navigationPath: $articlesPath)
                    .opacity(selectedTab == .articles ? 1 : 0)
                    .disabled(selectedTab != .articles)

                DirectoryListView(navigationPath: $directoryPath)
                    .opacity(selectedTab == .directory ? 1 : 0)
                    .disabled(selectedTab != .directory)

                InheritorsListView(navigationPath: $inheritorsPath)
                    .opacity(selectedTab == .inheritors ? 1 : 0)
                    .disabled(selectedTab != .inheritors)

                if selectedTab == .settings {
                    SettingsScreen(
                        themeMode: themeBinding,
                        languageMode: languageBinding,
                        onBack: { selectedTab = .articles }
                    )
                }
            }
        }
    }

    private var sidebar: some View {
        List(selection: $selectedTab) {
            Section {
                ForEach([SidebarItem.articles, .directory, .inheritors], id: \.self) { item in
                    Label(loc.localized(item.labelKey), systemImage: item.icon)
                        .tag(item)
                }
            }

            Section {
                Label(loc.localized("nav_settings"), systemImage: SidebarItem.settings.icon)
                    .tag(SidebarItem.settings)
            }

            Section {
                HStack {
                    Label(loc.localized("my_about"), systemImage: "info.circle")
                    Spacer()
                    Text("v0.1.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.sidebar)
        .background(theme.background)
    }

    // MARK: - Compact Layout (iPhone)

    private var compactLayout: some View {
        ZStack {
            if selectedTab == .settings {
                NavigationStack {
                    SettingsScreen(
                        themeMode: themeBinding,
                        languageMode: languageBinding,
                        onBack: { selectedTab = .articles }
                    )
                }
            } else {
                TabView(selection: Binding(
                    get: { selectedTab },
                    set: { selectedTab = $0 }
                )) {
                    ArticlesListView(navigationPath: $articlesPath, onSettings: { selectedTab = .settings })
                        .tabItem {
                            Label(loc.localized(SidebarItem.articles.labelKey), systemImage: SidebarItem.articles.icon)
                        }
                        .tag(SidebarItem.articles)

                    DirectoryListView(navigationPath: $directoryPath)
                        .tabItem {
                            Label(loc.localized(SidebarItem.directory.labelKey), systemImage: SidebarItem.directory.icon)
                        }
                        .tag(SidebarItem.directory)

                    InheritorsListView(navigationPath: $inheritorsPath)
                        .tabItem {
                            Label(loc.localized(SidebarItem.inheritors.labelKey), systemImage: SidebarItem.inheritors.icon)
                        }
                        .tag(SidebarItem.inheritors)
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
    @Binding var navigationPath: NavigationPath
    var onSettings: (() -> Void)? = nil
    @Environment(SavedContentRepository.self) private var savedContentRepo
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ArticlesScreen(navigationPath: $navigationPath, onSettings: onSettings)
                .navigationTitle("nav_articles")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    if let onSettings = onSettings {
                        #if os(iOS)
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: onSettings) { Image(systemName: "gearshape") }
                        }
                        #else
                        ToolbarItem(placement: .automatic) {
                            Button(action: onSettings) { Image(systemName: "gearshape") }
                        }
                        #endif
                    }
                }
                .navigationDestination(for: ArticleNavigationDestination.self) { dest in
                    switch dest {
                    case .articleDetail(let id, let sourceId, let sourceUrl, let category):
                        ArticleDetailScreen(
                            articleId: id,
                            sourceId: sourceId,
                            sourceUrl: sourceUrl,
                            category: category,
                            navigationPath: $navigationPath,
                            savedContentRepo: savedContentRepo
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
    @Binding var navigationPath: NavigationPath
    @Environment(SavedContentRepository.self) private var savedContentRepo

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
                            navigationPath: $navigationPath,
                            savedContentRepo: savedContentRepo
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
    @Binding var navigationPath: NavigationPath
    @Environment(SavedContentRepository.self) private var savedContentRepo

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
                            navigationPath: $navigationPath,
                            savedContentRepo: savedContentRepo
                        )
                    case .directoryDetail(let id, let sourceId, let kind):
                        DirectoryDetailScreen(
                            itemId: id,
                            sourceId: sourceId,
                            kind: kind,
                            navigationPath: $navigationPath,
                            savedContentRepo: savedContentRepo
                        )
                    }
                }
        }
    }
}
