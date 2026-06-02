import SwiftUI

/// 设置页
/// 完全对齐 Android SettingsScreen
struct SettingsView: View {
    @Environment(SettingsManager.self) private var settingsManager
    @Environment(\.heritageColorScheme) private var colorScheme

    let onBack: () -> Void
    let onMyPageClick: () -> Void

    var body: some View {
        @Bindable var settings = settingsManager

        PageBackground {
            ScrollView {
                VStack(spacing: 20) {
                    // 返回按钮和标题
                    HStack(spacing: 8) {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(colorScheme.onBackground)
                        }

                        Text("page.settings")
                            .font(HeritageTypography.headlineLarge)
                            .foregroundStyle(colorScheme.onBackground)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)

                    // 外观设置
                    SettingsSection(
                        titleKey: "settings.appearance",
                        groupTitleKey: "settings.theme"
                    ) {
                        ForEach(Array(ThemeMode.allCases.enumerated()), id: \.element) { index, mode in
                            SettingsOptionRow(
                                labelKey: mode.localizationKey,
                                selected: mode == settings.themeMode,
                                onClick: { settings.themeMode = mode }
                            )

                            if index != ThemeMode.allCases.count - 1 {
                                Divider()
                                    .background(colorScheme.outlineVariant)
                            }
                        }
                    }

                    // 语言设置
                    SettingsSection(
                        titleKey: "settings.language",
                        groupTitleKey: "settings.language"
                    ) {
                        ForEach(Array(LanguageMode.allCases.enumerated()), id: \.element) { index, mode in
                            SettingsOptionRow(
                                labelKey: mode.localizationKey,
                                selected: mode == settings.languageMode,
                                onClick: { settings.languageMode = mode }
                            )

                            if index != LanguageMode.allCases.count - 1 {
                                Divider()
                                    .background(colorScheme.outlineVariant)
                            }
                        }
                    }

                    // 我的页入口
                    ContentCard(onClick: onMyPageClick) {
                        HStack {
                            Text("settings.favoritesAndHistory")
                                .font(HeritageTypography.bodyLarge)
                                .foregroundStyle(colorScheme.onSurface)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                        }
                        .padding(14)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - 设置区块

private struct SettingsSection<Content: View>: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let titleKey: LocalizedStringKey
    let groupTitleKey: LocalizedStringKey
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 区块标题
            Text(titleKey)
                .font(HeritageTypography.titleLarge)
                .foregroundStyle(colorScheme.onBackground)

            // 选项卡片
            ContentCard {
                VStack(alignment: .leading, spacing: 0) {
                    // 组标题
                    Text(groupTitleKey)
                        .font(HeritageTypography.titleMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)

                    Divider()
                        .background(colorScheme.outlineVariant)

                    // 选项内容
                    content()
                }
            }
        }
    }
}

// MARK: - 设置选项行

private struct SettingsOptionRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let labelKey: LocalizedStringKey
    let selected: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Text(labelKey)
                    .font(HeritageTypography.bodyLarge)
                    .foregroundStyle(colorScheme.onSurface)

                Spacer()

                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(colorScheme.primary)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(selected ? colorScheme.surfaceContainerHigh : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(
        onBack: {},
        onMyPageClick: {}
    )
    .environment(SettingsManager.shared)
    .environment(\.heritageColorScheme, .light)
}
