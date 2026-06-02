import SwiftUI

/// 主题预览页面
/// 展示所有设计 token 和组件
struct ThemePreviewView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @Environment(SettingsManager.self) private var settingsManager

    @State private var searchText = ""

    var body: some View {
        @Bindable var settings = settingsManager

        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Theme Toggle
                section("主题切换") {
                    Picker("主题", selection: $settings.themeMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Colors
                section("颜色 Token") {
                    VStack(spacing: 12) {
                        colorRow("Primary", colorScheme.primary)
                        colorRow("On Primary", colorScheme.onPrimary)
                        colorRow("Primary Container", colorScheme.primaryContainer)
                        colorRow("Secondary", colorScheme.secondary)
                        colorRow("Secondary Container", colorScheme.secondaryContainer)
                        colorRow("Tertiary", colorScheme.tertiary)
                        colorRow("Background", colorScheme.background)
                        colorRow("Surface", colorScheme.surface)
                        colorRow("Surface Container Low", colorScheme.surfaceContainerLow)
                        colorRow("Surface Container High", colorScheme.surfaceContainerHigh)
                        colorRow("On Surface", colorScheme.onSurface)
                        colorRow("On Surface Variant", colorScheme.onSurfaceVariant)
                        colorRow("Outline", colorScheme.outline)
                        colorRow("Outline Variant", colorScheme.outlineVariant)
                    }
                }

                // MARK: - Typography
                section("字体 Token") {
                    VStack(alignment: .leading, spacing: 12) {
                        typographyRow("Display Small", font: HeritageTypography.displaySmall)
                        typographyRow("Headline Large", font: HeritageTypography.headlineLarge)
                        typographyRow("Headline Medium", font: HeritageTypography.headlineMedium)
                        typographyRow("Headline Small", font: HeritageTypography.headlineSmall)
                        typographyRow("Title Large", font: HeritageTypography.titleLarge)
                        typographyRow("Title Medium", font: HeritageTypography.titleMedium)
                        typographyRow("Body Large", font: HeritageTypography.bodyLarge)
                        typographyRow("Body Medium", font: HeritageTypography.bodyMedium)
                        typographyRow("Label Large", font: HeritageTypography.labelLarge)
                    }
                }

                // MARK: - Cards
                section("卡片") {
                    VStack(spacing: 12) {
                        ContentCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("普通卡片")
                                    .font(HeritageTypography.titleMedium)
                                    .foregroundStyle(colorScheme.onSurface)
                                Text("这是卡片内容示例")
                                    .font(HeritageTypography.bodyMedium)
                                    .foregroundStyle(colorScheme.onSurfaceVariant)
                            }
                            .padding(16)
                        }

                        FactCard(items: [
                            .init(label: "类别", value: "传统技艺"),
                            .init(label: "地区", value: "北京市"),
                            .init(label: "批次", value: "第一批")
                        ])
                    }
                }

                // MARK: - Chips
                section("Chips") {
                    HStack(spacing: 8) {
                        MetaChip("新闻")
                        MetaChip("论坛", isSelected: true)
                        MetaChip("专题")
                        MetaChip("国家级项目")
                    }
                }

                // MARK: - Search Field
                section("搜索框") {
                    SearchField(text: $searchText, placeholder: "搜索文章")
                }

                // MARK: - Buttons
                section("按钮") {
                    HStack(spacing: 16) {
                        Button("主要按钮") {}
                            .buttonStyle(.borderedProminent)
                            .tint(colorScheme.primary)

                        Button("次要按钮") {}
                            .buttonStyle(.bordered)
                            .tint(colorScheme.secondary)

                        FilterButton(activeCount: 2, action: {})
                    }
                }

                // MARK: - Error States
                section("错误状态") {
                    VStack(spacing: 12) {
                        ErrorRetryRow(message: "网络连接错误", retryAction: {})

                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(colorScheme.error)
                            Text("错误文本示例")
                                .foregroundStyle(colorScheme.error)
                        }
                    }
                }

                // MARK: - Loading States
                section("加载状态") {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(colorScheme.primary)

                        ListLoadingPlaceholder(count: 2)
                    }
                }

                // MARK: - Empty State
                section("空状态") {
                    EmptyState(
                        icon: "tray",
                        title: "暂无内容",
                        message: "这是空状态示例"
                    )
                    .frame(height: 200)
                }

                // MARK: - List Cards
                section("列表卡片") {
                    VStack(spacing: 12) {
                        ListCard(
                            title: "文章标题示例",
                            subtitle: "副标题文本",
                            category: "新闻",
                            date: "2024-01-15"
                        )

                        ListCard(
                            title: "突出显示的文章标题",
                            summary: "这是一段摘要文本，用于展示突出显示的卡片布局效果",
                            category: "专题",
                            date: "2024-01-15",
                            isProminent: true
                        )
                    }
                }

                // MARK: - Reference Card
                section("引用卡片") {
                    ReferenceCard(
                        title: "相关文章标题",
                        subtitle: "文章摘要文本",
                        type: "文章",
                        imageURL: nil
                    )
                }
            }
            .padding(20)
        }
        .navigationTitle("主题预览")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            content()
        }
    }

    private func colorRow(_ name: String, _ color: Color) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(colorScheme.outlineVariant, lineWidth: 1)
                )

            Text(name)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurface)

            Spacer()
        }
    }

    private func typographyRow(_ name: String, font: Font) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text("示例文本 Sample Text")
                .font(font)
                .foregroundStyle(colorScheme.onSurface)
        }
    }
}

#Preview {
    NavigationStack {
        ThemePreviewView()
    }
    .environment(\.heritageColorScheme, .light)
    .environment(SettingsManager.shared)
}
