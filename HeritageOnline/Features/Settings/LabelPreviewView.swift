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
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - 内容类型
                section("内容类型 (contentType)") {
                    labelTable([
                        ("article", ContentLabels.localizedContentType("article")),
                        ("directoryItem", ContentLabels.localizedContentType("directoryItem")),
                        ("inheritor", ContentLabels.localizedContentType("inheritor")),
                        ("collection", ContentLabels.localizedContentType("collection")),
                        ("topic", ContentLabels.localizedContentType("topic")),
                        ("(未知值)", ContentLabels.localizedContentType("unknownType")),
                    ])
                }

                // MARK: - 文章分类
                section("文章分类 (articleCategory)") {
                    labelTable([
                        ("news", ContentLabels.localizedArticleCategory("news") ?? ""),
                        ("forum", ContentLabels.localizedArticleCategory("forum") ?? ""),
                        ("specialTopic", ContentLabels.localizedArticleCategory("specialTopic") ?? ""),
                        ("(空值)", ContentLabels.localizedArticleCategory(nil) ?? "(nil)"),
                        ("(未知值)", ContentLabels.localizedArticleCategory("unknown") ?? ""),
                    ])
                }

                // MARK: - 名录种类
                section("名录种类 (directoryKind)") {
                    labelTable([
                        ("nationalProject", ContentLabels.localizedDirectoryKind("nationalProject") ?? ""),
                        ("culturalEcoZone", ContentLabels.localizedDirectoryKind("culturalEcoZone") ?? ""),
                        ("productiveProtectionBase", ContentLabels.localizedDirectoryKind("productiveProtectionBase") ?? ""),
                        ("unescoEntry", ContentLabels.localizedDirectoryKind("unescoEntry") ?? ""),
                        ("chinaUnescoEntry", ContentLabels.localizedDirectoryKind("chinaUnescoEntry") ?? ""),
                        ("contractingState", ContentLabels.localizedDirectoryKind("contractingState") ?? ""),
                        ("(空值)", ContentLabels.localizedDirectoryKind(nil) ?? "(nil)"),
                        ("(未知值)", ContentLabels.localizedDirectoryKind("unknown") ?? ""),
                    ])
                }

                // MARK: - 阅读路径来源
                section("阅读路径来源 (readingPathSource)") {
                    labelTable([
                        ("blendedRecommendation", ContentLabels.localizedReadingPathSource("blendedRecommendation")),
                        ("related", ContentLabels.localizedReadingPathSource("related")),
                        ("recommendation", ContentLabels.localizedReadingPathSource("recommendation")),
                        ("semanticRecommendation", ContentLabels.localizedReadingPathSource("semanticRecommendation")),
                        ("graph", ContentLabels.localizedReadingPathSource("graph")),
                        ("list", ContentLabels.localizedReadingPathSource("list")),
                        ("(未知值)", ContentLabels.localizedReadingPathSource("unknown")),
                    ])
                }

                // MARK: - 搜索结果类型
                section("搜索结果类型 (searchResultType)") {
                    labelTable([
                        ("article", ContentLabels.localizedSearchResultType("article") ?? ""),
                        ("directoryItem", ContentLabels.localizedSearchResultType("directoryItem") ?? ""),
                        ("inheritor", ContentLabels.localizedSearchResultType("inheritor") ?? ""),
                        ("(空值)", ContentLabels.localizedSearchResultType(nil) ?? "(nil)"),
                    ])
                }

                // MARK: - 发现类型
                section("发现类型 (discoveryType)") {
                    labelTable([
                        ("today", ContentLabels.localizedDiscoveryType("today") ?? ""),
                        ("trending", ContentLabels.localizedDiscoveryType("trending") ?? ""),
                        ("weekly", ContentLabels.localizedDiscoveryType("weekly") ?? ""),
                        ("serendipity", ContentLabels.localizedDiscoveryType("serendipity") ?? ""),
                        ("deepDive", ContentLabels.localizedDiscoveryType("deepDive") ?? ""),
                        ("(未知值)", ContentLabels.localizedDiscoveryType("unknown") ?? ""),
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

    private func labelTable(_ items: [(wireValue: String, displayValue: String)]) -> some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.wireValue) { item in
                    HStack(alignment: .top) {
                        Text(item.wireValue)
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.primary)
                            .frame(width: 140, alignment: .leading)

                        Text(item.displayValue)
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
