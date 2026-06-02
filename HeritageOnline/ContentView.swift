import SwiftUI

/// 应用主视图 - App Shell
/// 完全对齐 Android MainActivity HeritageApp
/// 实现四个底部导航、隐藏入口、二级页隐藏底部导航
struct ContentView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 当前选中的 tab
    @State private var selectedTab: HomeTab = .articles

    /// 是否显示设置页
    @State private var showSettings = false

    /// 是否显示我的页
    @State private var showMyPage = false

    /// 各 tab 是否在详情页（用于隐藏底部导航）
    @State private var articlesInDetail = false
    @State private var directoryInDetail = false
    @State private var inheritorsInDetail = false
    @State private var discoveryInDetail = false

    /// 当前 tab 是否在详情页
    private var currentTabInDetail: Bool {
        switch selectedTab {
        case .articles: return articlesInDetail
        case .directory: return directoryInDetail
        case .inheritors: return inheritorsInDetail
        case .discovery: return discoveryInDetail
        }
    }

    /// 是否显示底部导航
    private var shouldShowBottomBar: Bool {
        !showSettings && !showMyPage && !currentTabInDetail
    }

    var body: some View {
        @Bindable var settings = settingsManager

        ZStack {
            // 主内容
            TabView(selection: $selectedTab) {
                ArticlesTab(
                    onSettingsSelected: { showSettings = true },
                    onDetailChanged: { articlesInDetail = $0 }
                )
                .tabItem {
                    Label(String(localized: "tab.articles"), systemImage: HomeTab.articles.icon)
                }
                .tag(HomeTab.articles)

                DirectoryTab(
                    onDetailChanged: { directoryInDetail = $0 }
                )
                .tabItem {
                    Label(String(localized: "tab.directory"), systemImage: HomeTab.directory.icon)
                }
                .tag(HomeTab.directory)

                InheritorsTab(
                    onDetailChanged: { inheritorsInDetail = $0 }
                )
                .tabItem {
                    Label(String(localized: "tab.inheritors"), systemImage: HomeTab.inheritors.icon)
                }
                .tag(HomeTab.inheritors)

                DiscoveryTab(
                    onDetailChanged: { discoveryInDetail = $0 }
                )
                .tabItem {
                    Label(String(localized: "tab.discovery"), systemImage: HomeTab.discovery.icon)
                }
                .tag(HomeTab.discovery)
            }
            .tint(colorScheme.primary) // 选中文案颜色：primary
            .opacity(shouldShowBottomBar ? 1 : 0) // 隐藏 tab 时保持状态

            // 设置页覆盖层
            if showSettings {
                SettingsView(
                    onBack: { showSettings = false },
                    onMyPageClick: { showMyPage = true }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }

            // 我的页覆盖层
            if showMyPage {
                MyPageView(
                    onBack: { showMyPage = false },
                    onNavigate: { destination in
                        // 从我的页跳转到详情时，先关闭我的页，再切换到对应 tab
                        showMyPage = false
                        showSettings = false
                        switch destination {
                        case .article:
                            selectedTab = .articles
                        case .directory:
                            selectedTab = .directory
                        case .inheritor:
                            selectedTab = .inheritors
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
        }
        .animation(.default, value: showSettings)
        .animation(.default, value: showMyPage)
    }
}

// MARK: - Home Tab Enum

/// 主页 Tab 枚举
enum HomeTab: String, CaseIterable, Identifiable {
    case articles
    case directory
    case inheritors
    case discovery

    var id: String { rawValue }

    /// 本地化显示名称
    var displayName: String {
        switch self {
        case .articles: return String(localized: "tab.articles")
        case .directory: return String(localized: "tab.directory")
        case .inheritors: return String(localized: "tab.inheritors")
        case .discovery: return String(localized: "tab.discovery")
        }
    }

    /// SF Symbol 图标（对齐 Android Material Icons）
    /// Android: Article, CollectionsBookmark, Groups, Explore
    var icon: String {
        switch self {
        case .articles: return "doc.text"  // Article
        case .directory: return "books.vertical"  // CollectionsBookmark
        case .inheritors: return "person.2"  // Groups
        case .discovery: return "safari"  // Explore
        }
    }
}

// MARK: - Tab Views

/// 文章 Tab
struct ArticlesTab: View {
    let onSettingsSelected: () -> Void
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        NavigationStack {
            ArticlesListView(
                onSettingsSelected: onSettingsSelected,
                onDetailChanged: onDetailChanged
            )
        }
    }
}

/// 名录 Tab
struct DirectoryTab: View {
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        NavigationStack {
            DirectoryListView(onDetailChanged: onDetailChanged)
        }
    }
}

/// 传承人 Tab
struct InheritorsTab: View {
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        NavigationStack {
            InheritorsListView(onDetailChanged: onDetailChanged)
        }
    }
}

/// 发现 Tab
struct DiscoveryTab: View {
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        NavigationStack {
            DiscoveryView(onDetailChanged: onDetailChanged)
        }
    }
}

// MARK: - 占位页面

/// 文章列表占位页
struct ArticlesListView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onSettingsSelected: () -> Void
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(
                    title: "E迹",
                    subtitle: String(localized: "page.articles.subtitle"),
                    actions: [
                        .init(icon: "gear") { onSettingsSelected() },
                        .init(icon: "arrow.clockwise") { /* 刷新 */ }
                    ]
                )

                Spacer()

                Text(String(localized: "page.articles"))
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                Text(String(localized: "page.articles.placeholder"))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.top, 8)

                Spacer()
            }
        }
        .navigationTitle(String(localized: "tab.articles"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// 名录列表占位页
struct DirectoryListView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(
                    title: String(localized: "page.directory"),
                    subtitle: String(localized: "page.directory.subtitle")
                )

                Spacer()

                Text(String(localized: "page.directory"))
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                Text(String(localized: "page.directory.placeholder"))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.top, 8)

                Spacer()
            }
        }
        .navigationTitle(String(localized: "tab.directory"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// 传承人列表占位页
struct InheritorsListView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(
                    title: String(localized: "page.inheritors"),
                    subtitle: String(localized: "page.inheritors.subtitle")
                )

                Spacer()

                Text(String(localized: "page.inheritors"))
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                Text(String(localized: "page.inheritors.placeholder"))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.top, 8)

                Spacer()
            }
        }
        .navigationTitle(String(localized: "tab.inheritors"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

/// 发现页占位页
struct DiscoveryView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onDetailChanged: (Bool) -> Void

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(
                    title: String(localized: "page.discovery"),
                    subtitle: String(localized: "page.discovery.subtitle")
                )

                Spacer()

                Text(String(localized: "page.discovery"))
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                Text(String(localized: "page.discovery.placeholder"))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.top, 8)

                Spacer()
            }
        }
        .navigationTitle(String(localized: "tab.discovery"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - 设置页占位

struct SettingsView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onBack: () -> Void
    let onMyPageClick: () -> Void

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack {
                    PageHeader(title: String(localized: "page.settings"))

                    Spacer()

                    Text(String(localized: "page.settings"))
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    Button(String(localized: "settings.favoritesAndHistory")) {
                        onMyPageClick()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(colorScheme.primary)
                    .padding(.top, 16)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "page.settings"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "nav.back")) {
                        onBack()
                    }
                }
            }
            #endif
        }
    }
}

// MARK: - 我的页占位

enum MyPageDestination {
    case article
    case directory
    case inheritor
}

struct MyPageView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onBack: () -> Void
    let onNavigate: (MyPageDestination) -> Void

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack {
                    PageHeader(title: String(localized: "page.my"))

                    Spacer()

                    Text(String(localized: "page.my"))
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    Text(String(localized: "page.my.placeholder"))
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .padding(.top, 8)

                    Spacer()
                }
            }
            .navigationTitle(String(localized: "page.my"))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "nav.back")) {
                        onBack()
                    }
                }
            }
            #endif
        }
    }
}

#Preview {
    ContentView()
        .environment(SettingsManager.shared)
        .heritageTheme()
}
