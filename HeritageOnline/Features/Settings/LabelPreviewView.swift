import SwiftUI

/// 标签预览页面
/// 展示所有 wire value 本地化转换结果
struct LabelPreviewView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @Environment(SettingsManager.self) private var settingsManager

    var body: some View {
        @Bindable var settings = settingsManager

        ScrollView {
            VStack(spacing: 24) {
                // MARK: - 语言切换
                section("语言切换") {
                    Picker("语言", selection: $settings.languageMode) {
                        ForEach(LanguageMode.allCases) { mode in
                            Text(mode.localizationKey).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - 内容类型
                section("内容类型 (contentType)") {
                    labelTable([
                        ("article", ContentLabels.contentTypeKey("article")),
                        ("directoryItem", ContentLabels.contentTypeKey("directoryItem")),
                        ("inheritor", ContentLabels.contentTypeKey("inheritor")),
                        ("collection", ContentLabels.contentTypeKey("collection")),
                        ("topic", ContentLabels.contentTypeKey("topic")),
                        ("(未知值)", ContentLabels.contentTypeKey("unknownType")),
                    ])
                }

                // MARK: - 文章分类
                section("文章分类 (articleCategory)") {
                    labelTable([
                        ("news", ContentLabels.articleCategoryKey("news") ?? ""),
                        ("forum", ContentLabels.articleCategoryKey("forum") ?? ""),
                        ("specialTopic", ContentLabels.articleCategoryKey("specialTopic") ?? ""),
                        ("(空值)", ContentLabels.articleCategoryKey(nil) ?? "(nil)"),
                        ("(未知值)", ContentLabels.articleCategoryKey("unknown") ?? ""),
                    ])
                }

                // MARK: - 名录种类
                section("名录种类 (directoryKind)") {
                    labelTable([
                        ("nationalProject", ContentLabels.directoryKindKey("nationalProject") ?? ""),
                        ("culturalEcoZone", ContentLabels.directoryKindKey("culturalEcoZone") ?? ""),
                        ("productiveProtectionBase", ContentLabels.directoryKindKey("productiveProtectionBase") ?? ""),
                        ("unescoEntry", ContentLabels.directoryKindKey("unescoEntry") ?? ""),
                        ("chinaUnescoEntry", ContentLabels.directoryKindKey("chinaUnescoEntry") ?? ""),
                        ("contractingState", ContentLabels.directoryKindKey("contractingState") ?? ""),
                        ("(空值)", ContentLabels.directoryKindKey(nil) ?? "(nil)"),
                        ("(未知值)", ContentLabels.directoryKindKey("unknown") ?? ""),
                    ])
                }

                // MARK: - 阅读路径来源
                section("阅读路径来源 (readingPathSource)") {
                    labelTable([
                        ("blendedRecommendation", ContentLabels.readingPathSourceKey("blendedRecommendation")),
                        ("related", ContentLabels.readingPathSourceKey("related")),
                        ("recommendation", ContentLabels.readingPathSourceKey("recommendation")),
                        ("semanticRecommendation", ContentLabels.readingPathSourceKey("semanticRecommendation")),
                        ("graph", ContentLabels.readingPathSourceKey("graph")),
                        ("list", ContentLabels.readingPathSourceKey("list")),
                        ("(未知值)", ContentLabels.readingPathSourceKey("unknown")),
                    ])
                }

                // MARK: - 搜索结果类型
                section("搜索结果类型 (searchResultType)") {
                    labelTable([
                        ("article", ContentLabels.searchResultTypeKey("article") ?? ""),
                        ("directoryItem", ContentLabels.searchResultTypeKey("directoryItem") ?? ""),
                        ("inheritor", ContentLabels.searchResultTypeKey("inheritor") ?? ""),
                        ("(空值)", ContentLabels.searchResultTypeKey(nil) ?? "(nil)"),
                    ])
                }

                // MARK: - 发现类型
                section("发现类型 (discoveryType)") {
                    labelTable([
                        ("today", ContentLabels.discoveryTypeKey("today") ?? ""),
                        ("trending", ContentLabels.discoveryTypeKey("trending") ?? ""),
                        ("weekly", ContentLabels.discoveryTypeKey("weekly") ?? ""),
                        ("serendipity", ContentLabels.discoveryTypeKey("serendipity") ?? ""),
                        ("deepDive", ContentLabels.discoveryTypeKey("deepDive") ?? ""),
                        ("(未知值)", ContentLabels.discoveryTypeKey("unknown") ?? ""),
                    ])
                }
            }
            .padding(20)
        }
        .navigationTitle("标签预览")
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

    private func labelTable(_ items: [(wireValue: String, displayKey: String)]) -> some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.wireValue) { item in
                    HStack(alignment: .top) {
                        Text(item.wireValue)
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.primary)
                            .frame(width: 140, alignment: .leading)

                        Text(LocalizedStringKey(item.displayKey))
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurface)

                        Spacer()
                    }
                }
            }
            .padding(14)
        }
    }
}

#Preview {
    NavigationStack {
        LabelPreviewView()
    }
    .environment(\.heritageColorScheme, .light)
    .environment(SettingsManager.shared)
}
