import SwiftUI

/// 应用级路由
/// 用于跨 tab 详情导航（我的页 -> 详情页）
enum AppRoute: Hashable {
    case article(articleId: String?, sourceId: String?, sourceUrl: String?, category: ArticleCategory)
    case directory(itemId: String?, sourceId: String?, kind: DirectoryItemKind)
    case inheritor(inheritorId: String?, sourceId: String?)
}

extension AppRoute: Identifiable {
    var id: String {
        switch self {
        case .article(let articleId, let sourceId, let sourceUrl, let category):
            return "article|\(articleId ?? "")|\(sourceId ?? "")|\(sourceUrl ?? "")|\(category.rawValue)"
        case .directory(let itemId, let sourceId, let kind):
            return "directory|\(itemId ?? "")|\(sourceId ?? "")|\(kind.rawValue)"
        case .inheritor(let inheritorId, let sourceId):
            return "inheritor|\(inheritorId ?? "")|\(sourceId ?? "")"
        }
    }
}

/// 应用主视图 - App Shell
/// 对齐 Android MainActivity HeritageApp
/// 使用 SwiftUI 默认 TabView 导航
struct ContentView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(\.heritageColorScheme) private var colorScheme

    /// 当前选中的 tab
    @State private var selectedTab: HomeTab = .articles

    /// 已挂载的 tab 集合（用于懒挂载后保活）
    @State private var mountedTabs: Set<HomeTab> = [.articles]

    /// 是否显示设置页
    @State private var showSettings = false

    /// 是否显示我的页
    @State private var showMyPage = false

    /// 每个 tab 独立的导航路径
    @State private var articlesPath = NavigationPath()
    @State private var directoryPath = NavigationPath()
    @State private var inheritorsPath = NavigationPath()
    @State private var discoveryPath = NavigationPath()

    var body: some View {
        ZStack {
            MobileTabShell(
                selectedTab: $selectedTab,
                articlesPath: $articlesPath,
                directoryPath: $directoryPath,
                inheritorsPath: $inheritorsPath,
                discoveryPath: $discoveryPath,
                onSettingsSelected: { showSettings = true }
            )

            // 设置页覆盖层
            if showSettings {
                SettingsView(
                    onBack: { showSettings = false },
                    onMyPageClick: { showMyPage = true }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }

            // 我的页覆盖层（iOS overlay）
            #if !os(macOS)
            if showMyPage {
                MyPageView(
                    onBack: { showMyPage = false },
                    onNavigate: { item in
                        navigateFromSavedContent(item)
                    },
                    onNavigateReadingPath: { event in
                        navigateFromReadingPath(event)
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(2)
            }
            #endif
        }
        .animation(.default, value: showSettings)
        #if !os(macOS)
        .animation(.default, value: showMyPage)
        #endif
        .onChange(of: selectedTab) { _, newValue in
            mountedTabs.insert(newValue)
        }
        // macOS: My Page 用 sheet 展示
        #if os(macOS)
        .sheet(isPresented: $showMyPage) {
            MyPageView(
                onBack: { showMyPage = false },
                onNavigate: { item in
                    navigateFromSavedContent(item)
                },
                onNavigateReadingPath: { event in
                    navigateFromReadingPath(event)
                }
            )
            .frame(minWidth: 760, idealWidth: 920, minHeight: 560, idealHeight: 680)
        }
        #endif
    }

    // MARK: - 导航方法

    /// 从收藏/最近浏览导航到详情
    private func navigateFromSavedContent(_ item: SavedContent) {
        showMyPage = false
        showSettings = false

        let tab = item.targetTab
        let route = buildRoute(for: item)
        mountedTabs.insert(tab)
        selectedTab = tab
        appendRoute(route, to: tab)
    }

    /// 从阅读路径导航到详情
    private func navigateFromReadingPath(_ event: ReadingPathEvent) {
        showMyPage = false
        showSettings = false

        let tab = event.targetTab
        let route = buildRoute(for: event)
        mountedTabs.insert(tab)
        selectedTab = tab
        appendRoute(route, to: tab)
    }

    /// 根据 SavedContent 构造路由
    private func buildRoute(for item: SavedContent) -> AppRoute {
        switch item.contentType {
        case .article:
            let category = ArticleCategory(rawValue: item.targetCategory ?? "") ?? .news
            return .article(
                articleId: item.targetId,
                sourceId: item.targetSourceId,
                sourceUrl: item.targetSourceUrl,
                category: category
            )
        case .directoryItem:
            let kind = DirectoryItemKind(rawValue: item.targetKind ?? "") ?? .nationalProject
            return .directory(
                itemId: item.targetId,
                sourceId: item.targetSourceId,
                kind: kind
            )
        case .inheritor:
            return .inheritor(
                inheritorId: item.targetId,
                sourceId: item.targetSourceId
            )
        }
    }

    /// 根据 ReadingPathEvent 构造路由
    private func buildRoute(for event: ReadingPathEvent) -> AppRoute {
        switch event.toType {
        case .article:
            let category = ArticleCategory(rawValue: event.toCategory ?? "") ?? .news
            return .article(
                articleId: event.toId,
                sourceId: event.toSourceId,
                sourceUrl: event.toSourceUrl,
                category: category
            )
        case .directoryItem:
            let kind = DirectoryItemKind(rawValue: event.toKind ?? "") ?? .nationalProject
            return .directory(
                itemId: event.toId,
                sourceId: event.toSourceId,
                kind: kind
            )
        case .inheritor:
            return .inheritor(
                inheritorId: event.toId,
                sourceId: event.toSourceId
            )
        }
    }

    /// 将路由追加到对应 tab 的导航栈
    private func appendRoute(_ route: AppRoute, to tab: HomeTab) {
        switch tab {
        case .articles:
            articlesPath.append(route)
        case .directory:
            directoryPath.append(route)
        case .inheritors:
            inheritorsPath.append(route)
        case .discovery:
            discoveryPath.append(route)
        }
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
    @Binding var path: NavigationPath
    let onSettingsSelected: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            ArticlesView(onSettingsSelected: onSettingsSelected)
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
}

/// 名录 Tab
struct DirectoryTab: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            DirectoryView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
}

/// 传承人 Tab
struct InheritorsTab: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            InheritorsView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
}

/// 发现 Tab
struct DiscoveryTab: View {
    @Binding var path: NavigationPath

    var body: some View {
        NavigationStack(path: $path) {
            DiscoveryView()
                .navigationDestination(for: AppRoute.self) { route in
                    destinationView(for: route)
                }
        }
    }
}

// MARK: - 路由目标视图

/// 根据 AppRoute 创建对应的详情视图
@MainActor
@ViewBuilder
private func destinationView(for route: AppRoute) -> some View {
    switch route {
    case .article(let articleId, let sourceId, let sourceUrl, let category):
        ArticleDetailView(
            articleId: articleId,
            sourceId: sourceId,
            sourceUrl: sourceUrl,
            category: category
        )
    case .directory(let itemId, let sourceId, let kind):
        DirectoryDetailView(
            itemId: itemId,
            sourceId: sourceId,
            kind: kind
        )
    case .inheritor(let inheritorId, let sourceId):
        InheritorDetailView(
            inheritorId: inheritorId,
            sourceId: sourceId
        )
    }
}

// MARK: - 占位页面

/// 占位详情页（用于 Step 7 验收）
struct PlaceholderDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let titleKey: LocalizedStringKey
    var subtitleKey: LocalizedStringKey?

    var body: some View {
        PageBackground {
            VStack {
                PageHeader(titleKey: titleKey)

                Spacer()

                VStack(spacing: 8) {
                    Text(titleKey)
                        .font(HeritageTypography.headlineLarge)
                        .foregroundStyle(colorScheme.onBackground)

                    if let subtitleKey {
                        Text(subtitleKey)
                            .font(HeritageTypography.bodyLarge)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }

                    Text("page.detail.placeholder")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .padding(.top, 4)
                }

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

// MARK: - 设置页（使用独立的 SettingsView）


#Preview {
    ContentView()
        .environment(SettingsManager.shared)
        .heritageTheme()
}
