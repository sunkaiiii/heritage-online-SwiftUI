import SwiftUI

/// iOS/iPadOS 底部 Tab 导航 Shell
/// 保留当前 TabView 行为，不使用侧栏
struct MobileTabShell: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @Binding var selectedTab: HomeTab
    @Binding var articlesPath: NavigationPath
    @Binding var directoryPath: NavigationPath
    @Binding var inheritorsPath: NavigationPath
    @Binding var discoveryPath: NavigationPath

    let onSettingsSelected: () -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            ArticlesTab(
                path: $articlesPath,
                onSettingsSelected: onSettingsSelected
            )
            .tabItem {
                Label(HomeTab.articles.localizationKey, systemImage: HomeTab.articles.icon)
            }
            .tag(HomeTab.articles)
            .accessibilityIdentifier("tab.articles")

            DirectoryTab(path: $directoryPath)
                .tabItem {
                    Label(HomeTab.directory.localizationKey, systemImage: HomeTab.directory.icon)
                }
                .tag(HomeTab.directory)
                .accessibilityIdentifier("tab.directory")

            InheritorsTab(path: $inheritorsPath)
                .tabItem {
                    Label(HomeTab.inheritors.localizationKey, systemImage: HomeTab.inheritors.icon)
                }
                .tag(HomeTab.inheritors)
                .accessibilityIdentifier("tab.inheritors")

            DiscoveryTab(path: $discoveryPath)
                .tabItem {
                    Label(HomeTab.discovery.localizationKey, systemImage: HomeTab.discovery.icon)
                }
                .tag(HomeTab.discovery)
                .accessibilityIdentifier("tab.discovery")
        }
        .tint(colorScheme.primary)
    }
}
