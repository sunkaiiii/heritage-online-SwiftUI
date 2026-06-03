import SwiftUI

/// 应用主视图 - App Shell
/// 对齐 Android MainActivity HeritageApp
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

    var body: some View {
        ZStack {
            // 主内容
            TabView(selection: $selectedTab) {
                ArticlesTab(onSettingsSelected: { showSettings = true })
                    .tabItem {
                        Label(HomeTab.articles.localizationKey, systemImage: HomeTab.articles.icon)
                    }
                    .tag(HomeTab.articles)

                DirectoryTab()
                    .tabItem {
                        Label(HomeTab.directory.localizationKey, systemImage: HomeTab.directory.icon)
                    }
                    .tag(HomeTab.directory)

                InheritorsTab()
                    .tabItem {
                        Label(HomeTab.inheritors.localizationKey, systemImage: HomeTab.inheritors.icon)
                    }
                    .tag(HomeTab.inheritors)

                DiscoveryTab()
                    .tabItem {
                        Label(HomeTab.discovery.localizationKey, systemImage: HomeTab.discovery.icon)
                    }
                    .tag(HomeTab.discovery)
            }
            .tint(colorScheme.primary)

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
                    onNavigate: { item in
                        showMyPage = false
                        showSettings = false
                        selectedTab = item.targetTab
                    },
                    onNavigateReadingPath: { event in
                        showMyPage = false
                        showSettings = false
                        selectedTab = event.targetTab
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

    /// 本地化显示名称 key
    var localizationKey: LocalizedStringKey {
        switch self {
        case .articles: return "tab.articles"
        case .directory: return "tab.directory"
        case .inheritors: return "tab.inheritors"
        case .discovery: return "tab.discovery"
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

    var body: some View {
        NavigationStack {
            ArticlesView(onSettingsSelected: onSettingsSelected)
        }
    }
}

/// 名录 Tab
struct DirectoryTab: View {
    var body: some View {
        NavigationStack {
            DirectoryView()
        }
    }
}

/// 传承人 Tab
struct InheritorsTab: View {
    var body: some View {
        NavigationStack {
            InheritorsView()
        }
    }
}

/// 发现 Tab
struct DiscoveryTab: View {
    var body: some View {
        NavigationStack {
            DiscoveryView()
        }
    }
}

// MARK: - 占位页面

/// 占位详情页（用于 Step 7 验收）
struct PlaceholderDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let titleKey: LocalizedStringKey

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(titleKey: titleKey)

                Spacer()

                Text(titleKey)
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                Text("page.detail.placeholder")
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.top, 8)

                Spacer()
            }
        }
        .navigationTitle(titleKey)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar) // 隐藏底部导航
        #endif
    }
}
/// 发现页占位页
struct DiscoveryView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(
                    titleKey: "page.discovery",
                    subtitleKey: "page.discovery.subtitle"
                )

                Spacer()

                Text("page.discovery")
                    .font(HeritageTypography.headlineLarge)
                    .foregroundStyle(colorScheme.onBackground)

                Text("page.discovery.placeholder")
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.top, 8)

                // 占位详情页按钮
                NavigationLink(destination: PlaceholderDetailView(titleKey: "page.discovery")) {
                    Text("action.viewDetail")
                        .font(HeritageTypography.labelLarge)
                        .foregroundStyle(colorScheme.primary)
                        .padding(.top, 16)
                }

                Spacer()
            }
        }
        .navigationTitle("tab.discovery")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

// MARK: - 设置页（使用独立的 SettingsView）


#Preview {
    ContentView()
        .environment(SettingsManager.shared)
        .heritageTheme()
}
