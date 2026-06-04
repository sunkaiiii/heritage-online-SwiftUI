import SwiftUI

/// 对比页面
/// 对齐 Android CompareScreen
/// 支持地区、分类、kind 对比
struct CompareView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel: CompareViewModel

    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?

    init(initialType: String? = nil, initialLeft: String? = nil, initialRight: String? = nil) {
        _viewModel = State(initialValue: CompareViewModel(initialType: initialType, initialLeft: initialLeft, initialRight: initialRight))
    }

    var body: some View {
        PageBackground {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    // 类型选择
                    CompareTypeSelector(
                        selectedType: viewModel.uiState.selectedType,
                        onTypeChange: { viewModel.updateType($0) }
                    )

                    // 输入区
                    CompareInputArea(
                        selectedType: viewModel.uiState.selectedType,
                        leftInput: Binding(
                            get: { viewModel.uiState.leftInput },
                            set: { viewModel.uiState.leftInput = $0 }
                        ),
                        rightInput: Binding(
                            get: { viewModel.uiState.rightInput },
                            set: { viewModel.uiState.rightInput = $0 }
                        )
                    )

                    // 开始对比按钮
                    Button(action: { viewModel.compare() }) {
                        HStack {
                            if viewModel.uiState.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(String(localized: "compare.start"))
                                .font(HeritageTypography.labelLarge)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewModel.uiState.isLoading)
                    .padding(.horizontal, 16)

                    // 错误信息
                    if let errorMessage = viewModel.uiState.errorMessage {
                        Text(String(localized: String.LocalizationValue(errorMessage)))
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.error)
                            .padding(.horizontal, 16)
                    }

                    if let error = viewModel.uiState.error {
                        Text(error.localizedDescription)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.error)
                            .padding(.horizontal, 16)
                    }

                    // 结果
                    if let result = viewModel.uiState.result {
                        CompareResultContent(
                            result: result,
                            onArticleClick: { navigateToArticle = $0 },
                            onDirectoryClick: { navigateToDirectory = $0 },
                            onInheritorClick: { navigateToInheritor = $0 }
                        )
                    }

                    Spacer().frame(height: 18)
                }
                .padding(.vertical, 18)
            }
        }
        .navigationTitle("page.compare")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .navigationDestination(item: $navigateToArticle) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToDirectory) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToInheritor) { id in
            InheritorDetailView(inheritorId: id)
        }
    }
}

// MARK: - Compare Type Selector

private struct CompareTypeSelector: View {
    let selectedType: CompareType
    let onTypeChange: (CompareType) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach([CompareType.region, .category, .kind], id: \.self) { type in
                Button(action: {
                    onTypeChange(type)
                }) {
                    Text(typeLabel(type))
                        .font(HeritageTypography.labelLarge)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(selectedType == type ? Color.accentColor : Color.clear)
                        .foregroundStyle(selectedType == type ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }

    private func typeLabel(_ type: CompareType) -> String {
        switch type {
        case .region: String(localized: "stats.regions")
        case .category: String(localized: "stats.categories")
        case .kind: String(localized: "stats.kind")
        }
    }
}

// MARK: - Compare Input Area

private struct CompareInputArea: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let selectedType: CompareType
    @Binding var leftInput: String
    @Binding var rightInput: String

    var body: some View {
        VStack(spacing: 12) {
            if selectedType == .kind {
                // Kind 使用下拉选择
                KindDropdown(
                    label: String(localized: "compare.left"),
                    selection: $leftInput
                )
                KindDropdown(
                    label: String(localized: "compare.right"),
                    selection: $rightInput
                )
            } else {
                // Region/Category 使用文本输入
                TextField(String(localized: "compare.leftPlaceholder"), text: $leftInput)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)

                TextField(String(localized: "compare.rightPlaceholder"), text: $rightInput)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Kind Dropdown

private struct KindDropdown: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let label: String
    @Binding var selection: String

    private let kinds: [DirectoryItemKind] = DirectoryItemKind.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Picker(label, selection: $selection) {
                Text(String(localized: "compare.selectKind")).tag("")
                ForEach(kinds, id: \.self) { kind in
                    Text(ContentLabels.localizedDirectoryKind(kind.rawValue) ?? kind.rawValue)
                        .tag(kind.rawValue)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Compare Result Content

private struct CompareResultContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let result: CompareResultDTO
    let onArticleClick: (String) -> Void
    let onDirectoryClick: (String) -> Void
    let onInheritorClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // 两侧概览
            HStack(spacing: 12) {
                CompareSideCard(side: result.left, color: colorScheme.primaryContainer)
                CompareSideCard(side: result.right, color: colorScheme.secondaryContainer)
            }
            .padding(.horizontal, 16)

            // Winner Summary
            CompareWinnerSummary(summary: result.summary)

            // Shared Categories
            if !result.sharedCategories.isEmpty {
                CompareChipsSection(
                    title: String(localized: "compare.sharedCategories"),
                    items: result.sharedCategories,
                    color: colorScheme.primaryContainer
                )
            }

            // Left Unique Categories
            if !result.leftUniqueCategories.isEmpty {
                CompareChipsSection(
                    title: String(format: String(localized: "compare.uniqueLeft %@"), result.left.title ?? ""),
                    items: result.leftUniqueCategories,
                    color: colorScheme.tertiaryContainer
                )
            }

            // Right Unique Categories
            if !result.rightUniqueCategories.isEmpty {
                CompareChipsSection(
                    title: String(format: String(localized: "compare.uniqueRight %@"), result.right.title ?? ""),
                    items: result.rightUniqueCategories,
                    color: colorScheme.tertiaryContainer
                )
            }

            // Shared/Unique Regions
            if !result.sharedRegions.isEmpty {
                CompareChipsSection(
                    title: String(localized: "compare.sharedRegions"),
                    items: result.sharedRegions,
                    color: colorScheme.primaryContainer
                )
            }

            if !result.leftUniqueRegions.isEmpty {
                CompareChipsSection(
                    title: String(format: String(localized: "compare.uniqueLeft %@"), result.left.title ?? ""),
                    items: result.leftUniqueRegions,
                    color: colorScheme.tertiaryContainer
                )
            }

            if !result.rightUniqueRegions.isEmpty {
                CompareChipsSection(
                    title: String(format: String(localized: "compare.uniqueRight %@"), result.right.title ?? ""),
                    items: result.rightUniqueRegions,
                    color: colorScheme.tertiaryContainer
                )
            }

            // Featured Items
            if !result.leftFeaturedItems.isEmpty {
                CompareFeaturedItems(
                    title: String(format: String(localized: "compare.featuredLeft %@"), result.left.title ?? ""),
                    items: result.leftFeaturedItems,
                    onArticleClick: onArticleClick,
                    onDirectoryClick: onDirectoryClick,
                    onInheritorClick: onInheritorClick
                )
            }

            if !result.rightFeaturedItems.isEmpty {
                CompareFeaturedItems(
                    title: String(format: String(localized: "compare.featuredRight %@"), result.right.title ?? ""),
                    items: result.rightFeaturedItems,
                    onArticleClick: onArticleClick,
                    onDirectoryClick: onDirectoryClick,
                    onInheritorClick: onInheritorClick
                )
            }
        }
    }
}

// MARK: - Compare Side Card

private struct CompareSideCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let side: CompareSideDTO
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(side.title ?? "")
                .font(HeritageTypography.titleMedium)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme.onSurface)
                .lineLimit(2)

            VStack(spacing: 4) {
                StatRow(label: String(localized: "stats.directoryItems"), value: side.directoryItemCount)
                StatRow(label: String(localized: "stats.inheritors"), value: side.inheritorCount)
                StatRow(label: String(localized: "stats.articles"), value: side.articleCount)
                StatRow(label: String(localized: "stats.total"), value: side.total)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct StatRow: View {
    let label: String
    let value: Int

    var body: some View {
        HStack {
            Text(label)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(value)")
                .font(HeritageTypography.bodyMedium)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Compare Winner Summary

private struct CompareWinnerSummary: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let summary: CompareSummaryDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SectionHeader(title: String(localized: "compare.summary"))

            if let winner = summary.winnerByTotal {
                WinnerRow(dimension: String(localized: "stats.total"), winner: winner)
            }
            if let winner = summary.winnerByDirectoryItems {
                WinnerRow(dimension: String(localized: "stats.directoryItems"), winner: winner)
            }
            if let winner = summary.winnerByInheritors {
                WinnerRow(dimension: String(localized: "stats.inheritors"), winner: winner)
            }
            if let winner = summary.winnerByArticles {
                WinnerRow(dimension: String(localized: "stats.articles"), winner: winner)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct WinnerRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let dimension: String
    let winner: String

    var body: some View {
        HStack {
            Text(dimension)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
            Spacer()
            Text(winner)
                .font(HeritageTypography.bodyMedium)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme.primary)
        }
    }
}

// MARK: - Compare Chips Section

private struct CompareChipsSection: View {
    let title: String
    let items: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)
            FlowLayout(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Text(item)
                        .font(HeritageTypography.bodyMedium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Compare Featured Items

private struct CompareFeaturedItems: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let title: String
    let items: [CollectionItemDTO]
    let onArticleClick: (String) -> Void
    let onDirectoryClick: (String) -> Void
    let onInheritorClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Button(action: {
                    guard let id = item.id else { return }
                    switch item.type {
                    case "article": onArticleClick(id)
                    case "directoryItem": onDirectoryClick(id)
                    case "inheritor": onInheritorClick(id)
                    default: break
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title ?? "")
                                .font(HeritageTypography.titleMedium)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            if let category = item.category {
                                Text(ContentLabels.localizedArticleCategory(category) ?? category)
                                    .font(HeritageTypography.bodyMedium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(colorScheme.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        CompareView()
    }
    .heritageTheme()
}
