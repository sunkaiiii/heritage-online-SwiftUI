import SwiftUI

/// Tab 内容保活容器
/// 使用系统 TabView 保活每个 tab 的 NavigationStack
struct TabContentHost: View {
    @Binding var selectedTab: HomeTab
    @Binding var mountedTabs: Set<HomeTab>
    @Binding var articlesPath: NavigationPath
    @Binding var directoryPath: NavigationPath
    @Binding var inheritorsPath: NavigationPath
    @Binding var discoveryPath: NavigationPath

    let onSettingsSelected: () -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            ArticlesTab(path: $articlesPath, onSettingsSelected: onSettingsSelected)
                .tag(HomeTab.articles)

            DirectoryTab(path: $directoryPath)
                .tag(HomeTab.directory)

            InheritorsTab(path: $inheritorsPath)
                .tag(HomeTab.inheritors)

            DiscoveryTab(path: $discoveryPath)
                .tag(HomeTab.discovery)
        }
        .onChange(of: selectedTab) { _, tab in
            mountedTabs.insert(tab)
        }
    }
}
