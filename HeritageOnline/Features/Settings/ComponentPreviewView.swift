import SwiftUI

/// 组件预览页面
/// 展示所有共享 UI 组件，用于开发和测试
struct ComponentPreviewView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @Environment(SettingsManager.self) private var settingsManager

    @State private var searchText = ""
    @State private var showSheet = false

    var body: some View {
        @Bindable var settings = settingsManager

        ScrollView {
            VStack(spacing: 24) {
                // MARK: - 主题切换
                section("主题与语言") {
                    VStack(spacing: 12) {
                        Picker("主题", selection: $settings.themeMode) {
                            ForEach(ThemeMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        Picker("语言", selection: $settings.languageMode) {
                            ForEach(LanguageMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // MARK: - PageBackground
                section("PageBackground") {
                    Text("页面背景使用 background 颜色")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }

                // MARK: - PageHeader
                section("PageHeader") {
                    PageHeader(
                        title: "E迹",
                        subtitle: "非遗新闻、论坛与专题",
                        actions: [
                            .init(icon: "gear") { showSheet = true },
                            .init(icon: "arrow.clockwise") {}
                        ]
                    )
                    .background(colorScheme.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                }

                // MARK: - SectionHeader
                section("SectionHeader") {
                    VStack(spacing: 16) {
                        SectionHeader(title: "最新文章")
                        SectionHeader(title: "Featured Collections")
                    }
                    .padding()
                    .background(colorScheme.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                }

                // MARK: - ContentCard
                section("ContentCard") {
                    VStack(spacing: 12) {
                        ContentCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("普通卡片")
                                    .font(HeritageTypography.titleMedium)
                                    .foregroundStyle(colorScheme.onSurface)
                                Text("不可点击的内容卡片")
                                    .font(HeritageTypography.bodyMedium)
                                    .foregroundStyle(colorScheme.onSurfaceVariant)
                            }
                            .padding(16)
                        }

                        ContentCard(onClick: {}) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("可点击卡片")
                                    .font(HeritageTypography.titleMedium)
                                    .foregroundStyle(colorScheme.onSurface)
                                Text("点击查看详情")
                                    .font(HeritageTypography.bodyMedium)
                                    .foregroundStyle(colorScheme.onSurfaceVariant)
                            }
                            .padding(16)
                        }
                    }
                }

                // MARK: - MetaChip
                section("MetaChip") {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            MetaChip("新闻")
                            MetaChip("论坛")
                            MetaChip("专题")
                            MetaChip("国家级项目")
                        }

                        HStack(spacing: 8) {
                            MetaChip("传统技艺", isSelected: true)
                            MetaChip("北京市")
                            MetaChip("第一批")
                        }

                        // 长文本省略测试
                        MetaChip("这是一个非常长的标签文本用于测试省略效果")
                    }
                }

                // MARK: - ImagePlaceholder
                section("ImagePlaceholder") {
                    HStack(spacing: 12) {
                        ImagePlaceholder(label: "E迹", width: 100, height: 80)
                        ImagePlaceholder(label: "非遗", width: 100, height: 80)
                        ImagePlaceholder(label: "传承", width: 100, height: 80)
                    }
                }

                // MARK: - ListImage
                section("ListImage") {
                    HStack(spacing: 12) {
                        ListImage(url: nil, title: "无图片", width: 100, height: 80)
                        ListImage(url: nil, title: "测试标题", width: 100, height: 80)
                    }
                }

                // MARK: - ListCard
                section("ListCard") {
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

                        // 英文长标题测试
                        ListCard(
                            title: "This is a very long English article title for testing overflow behavior",
                            subtitle: "Subtitle text",
                            category: "News",
                            date: "2024-01-15"
                        )
                    }
                }

                // MARK: - FactCard
                section("FactCard") {
                    FactCard(items: [
                        .init(label: "类别", value: "传统技艺"),
                        .init(label: "地区", value: "北京市"),
                        .init(label: "批次", value: "第一批"),
                        .init(label: "年份", value: "2006"),
                        .init(label: "保护单位", value: "中国艺术研究院")
                    ])
                }

                // MARK: - ReferenceCard
                section("ReferenceCard") {
                    VStack(spacing: 12) {
                        ReferenceCard(
                            title: "相关文章标题",
                            subtitle: "文章摘要文本",
                            type: "文章",
                            imageURL: nil
                        )

                        ReferenceCard(
                            title: "Related Directory Item",
                            subtitle: "Directory description",
                            type: "Directory",
                            imageURL: nil
                        )
                    }
                }

                // MARK: - SearchField
                section("SearchField") {
                    VStack(spacing: 12) {
                        SearchField(text: $searchText, placeholder: "搜索文章")
                        SearchField(text: $searchText, placeholder: "Search articles")
                    }
                }

                // MARK: - FilterButton
                section("FilterButton") {
                    HStack(spacing: 20) {
                        VStack {
                            FilterButton(activeCount: 0, action: {})
                            Text("无筛选")
                                .font(HeritageTypography.labelMedium)
                        }

                        VStack {
                            FilterButton(activeCount: 2, action: {})
                            Text("2个筛选")
                                .font(HeritageTypography.labelMedium)
                        }

                        VStack {
                            FilterButton(activeCount: 5, action: {})
                            Text("5个筛选")
                                .font(HeritageTypography.labelMedium)
                        }
                    }
                }

                // MARK: - ErrorRetryRow
                section("ErrorRetryRow") {
                    VStack(spacing: 12) {
                        ErrorRetryRow(message: "网络连接错误", retryAction: {})
                        ErrorRetryRow(message: "Network connection error", retryAction: {})
                        ErrorRetryRow(message: "请求超时，请稍后重试", retryAction: {})
                    }
                }

                // MARK: - LoadingPlaceholder
                section("LoadingPlaceholder") {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(colorScheme.primary)

                        ListLoadingPlaceholder(count: 2)
                    }
                }

                // MARK: - EmptyState
                section("EmptyState") {
                    VStack(spacing: 12) {
                        EmptyState(
                            icon: "tray",
                            title: "暂无内容",
                            message: "这是空状态示例"
                        )
                        .frame(height: 150)

                        EmptyState(
                            icon: "doc.text.magnifyingglass",
                            title: "No results found",
                            message: "Try different keywords or filters"
                        )
                        .frame(height: 150)
                    }
                }

                // MARK: - 按钮样式
                section("按钮样式") {
                    HStack(spacing: 16) {
                        Button("主要按钮") {}
                            .buttonStyle(.borderedProminent)
                            .tint(colorScheme.primary)

                        Button("次要按钮") {}
                            .buttonStyle(.bordered)
                            .tint(colorScheme.secondary)

                        Button("文字按钮") {}
                            .foregroundStyle(colorScheme.primary)
                    }
                }

                // MARK: - 颜色预览
                section("颜色预览") {
                    VStack(spacing: 8) {
                        colorRow("Primary", colorScheme.primary)
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

                // MARK: - 字体预览
                section("字体预览") {
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
            }
            .padding(20)
        }
        .navigationTitle("组件预览")
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

            Text("示例文本 Sample Text 示例文本")
                .font(font)
                .foregroundStyle(colorScheme.onSurface)
        }
    }
}

#Preview {
    NavigationStack {
        ComponentPreviewView()
    }
    .environment(\.heritageColorScheme, .light)
    .environment(SettingsManager.shared)
}
