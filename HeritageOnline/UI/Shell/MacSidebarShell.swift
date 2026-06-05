#if os(macOS)
import SwiftUI

/// macOS 左侧栏导航 Shell
/// 类似 Apple Music 的侧栏布局
struct MacSidebarShell: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @Binding var selectedTab: HomeTab
    @Binding var mountedTabs: Set<HomeTab>
    @Binding var articlesPath: NavigationPath
    @Binding var directoryPath: NavigationPath
    @Binding var inheritorsPath: NavigationPath
    @Binding var discoveryPath: NavigationPath

    let onSettingsSelected: () -> Void
    let onMyPageSelected: () -> Void

    private let sidebarWidth: CGFloat = 236

    var body: some View {
        HStack(spacing: 0) {
            MacSidebar(
                selectedTab: $selectedTab,
                onSettingsSelected: onSettingsSelected,
                onMyPageSelected: onMyPageSelected
            )
            .frame(width: sidebarWidth)

            Divider()

            TabContentHost(
                selectedTab: $selectedTab,
                mountedTabs: $mountedTabs,
                articlesPath: $articlesPath,
                directoryPath: $directoryPath,
                inheritorsPath: $inheritorsPath,
                discoveryPath: $discoveryPath,
                onSettingsSelected: onSettingsSelected
            )
        }
        .background(colorScheme.background)
    }
}

// MARK: - macOS 侧栏

/// macOS 侧栏导航组件
private struct MacSidebar: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @Binding var selectedTab: HomeTab

    let onSettingsSelected: () -> Void
    let onMyPageSelected: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 顶部间距（traffic light 空间）
            Spacer()
                .frame(height: 28)

            // 应用标题
            Text("app.name")
                .font(HeritageTypography.titleLarge)
                .foregroundStyle(colorScheme.onBackground)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

            // 主导航
            VStack(alignment: .leading, spacing: 4) {
                ForEach(HomeTab.allCases) { tab in
                    MacSidebarItem(
                        tab: tab,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal, 8)

            Spacer()

            // 工具入口
            VStack(alignment: .leading, spacing: 4) {
                MacSidebarButton(
                    icon: "person.circle",
                    titleKey: "tab.myPage",
                    identifier: "tab.myPage"
                ) {
                    onMyPageSelected()
                }

                MacSidebarButton(
                    icon: "gear",
                    titleKey: "tab.settings",
                    identifier: "tab.settings"
                ) {
                    onSettingsSelected()
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(colorScheme.surface)
    }
}

// MARK: - 侧栏导航项

/// macOS 侧栏栏目导航按钮
private struct MacSidebarItem: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let tab: HomeTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16))
                    .frame(width: 24)
                Text(tab.localizationKey)
                    .font(HeritageTypography.titleMedium)
                Spacer()
            }
            .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? colorScheme.primaryContainer : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("tab.\(tab.rawValue)")
    }
}

// MARK: - 侧栏工具按钮

/// macOS 侧栏工具入口按钮（我的页、设置等）
private struct MacSidebarButton: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let icon: String
    let titleKey: LocalizedStringKey
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .frame(width: 24)
                Text(titleKey)
                    .font(HeritageTypography.titleMedium)
                Spacer()
            }
            .foregroundStyle(colorScheme.onSurface)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }
}
#endif
