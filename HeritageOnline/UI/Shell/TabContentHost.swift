import SwiftUI

/// Tab 内容保活容器
/// 使用 ZStack + opacity 实现懒挂载后保活
/// 未选中的栏目隐藏但不销毁，保留滚动状态和 NavigationPath
struct TabContentHost: View {
    @Binding var selectedTab: HomeTab
    @Binding var mountedTabs: Set<HomeTab>
    @Binding var articlesPath: NavigationPath
    @Binding var directoryPath: NavigationPath
    @Binding var inheritorsPath: NavigationPath
    @Binding var discoveryPath: NavigationPath

    let onSettingsSelected: () -> Void

    var body: some View {
        ZStack {
            if mountedTabs.contains(.articles) {
                keptAlive(.articles) {
                    ArticlesTab(path: $articlesPath, onSettingsSelected: onSettingsSelected)
                }
            }

            if mountedTabs.contains(.directory) {
                keptAlive(.directory) {
                    DirectoryTab(path: $directoryPath)
                }
            }

            if mountedTabs.contains(.inheritors) {
                keptAlive(.inheritors) {
                    InheritorsTab(path: $inheritorsPath)
                }
            }

            if mountedTabs.contains(.discovery) {
                keptAlive(.discovery) {
                    DiscoveryTab(path: $discoveryPath)
                }
            }
        }
    }

    @ViewBuilder
    private func keptAlive<Content: View>(
        _ tab: HomeTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .opacity(selectedTab == tab ? 1 : 0)
            .allowsHitTesting(selectedTab == tab)
            .accessibilityHidden(selectedTab != tab)
    }
}
