import SwiftUI

/// SwiftUI 默认 Tab 导航 Shell
/// macOS 显示为窗口顶部 tab，iOS/iPadOS 显示为底部 tab
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
