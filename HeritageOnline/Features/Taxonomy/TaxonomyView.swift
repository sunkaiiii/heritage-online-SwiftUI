import SwiftUI

/// 主题库页面
/// 对齐 Android TaxonomyScreen
/// 三个 tab：分类、地区、种类
struct TaxonomyView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel = TaxonomyViewModel()

    @State private var selectedTab = 0
    @State private var navigateToDetail: TopicNavigation?
    @State private var navigateToCompare: CompareNavigation?

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.uiState.isLoading && viewModel.uiState.categories.isEmpty {
                    LoadingPlaceholder()
                } else if let error = viewModel.uiState.error {
                    errorView(error)
                } else {
                    TaxonomyContent(
                        categories: viewModel.uiState.categories,
                        regions: viewModel.uiState.regions,
                        kinds: viewModel.uiState.kinds,
                        selectedTab: $selectedTab,
                        onTopicClick: { type, key in
                            if type == "kind" {
                                // 种类没有详情页，直接进入对比
                                navigateToCompare = CompareNavigation(type: "kind", left: key)
                            } else {
                                navigateToDetail = TopicNavigation(type: type, key: key)
                            }
                        }
                    )
                }
            }
        }
        .navigationTitle("page.taxonomy")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadAll()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.uiState.categories.isEmpty && viewModel.uiState.error == nil {
                viewModel.loadAll()
            }
        }
        .navigationDestination(item: $navigateToDetail) { nav in
            TaxonomyDetailView(type: nav.type, key: nav.key)
        }
        .navigationDestination(item: $navigateToCompare) { nav in
            CompareView(initialType: nav.type, initialLeft: nav.left)
        }
    }

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)
            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)
            Button("action.retry") { viewModel.loadAll() }
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Taxonomy Content

private struct TaxonomyContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let categories: [TaxonomyTopicDTO]
    let regions: [TaxonomyTopicDTO]
    let kinds: [TaxonomyKindDTO]
    @Binding var selectedTab: Int
    let onTopicClick: (String, String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Tab 选择器
            Picker("Tab", selection: $selectedTab) {
                Text(String(localized: "taxonomy.tab.categories")).tag(0)
                Text(String(localized: "taxonomy.tab.regions")).tag(1)
                Text(String(localized: "taxonomy.tab.kinds")).tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // 内容
            TabView(selection: $selectedTab) {
                TaxonomyTopicList(
                    topics: categories,
                    type: "category",
                    onTopicClick: onTopicClick
                )
                .tag(0)

                TaxonomyTopicList(
                    topics: regions,
                    type: "region",
                    onTopicClick: onTopicClick
                )
                .tag(1)

                TaxonomyKindList(
                    kinds: kinds,
                    onKindClick: { key in onTopicClick("kind", key) }
                )
                .tag(2)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
    }
}

// MARK: - Taxonomy Topic List

private struct TaxonomyTopicList: View {
    let topics: [TaxonomyTopicDTO]
    let type: String
    let onTopicClick: (String, String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(topics.enumerated()), id: \.offset) { _, topic in
                    TaxonomyTopicCard(topic: topic) {
                        if let key = topic.key {
                            onTopicClick(type, key)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .padding(.bottom, 18)
        }
    }
}

// MARK: - Taxonomy Topic Card

private struct TaxonomyTopicCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let topic: TaxonomyTopicDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            ContentCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text(topic.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    if let subtitle = topic.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    HStack(spacing: 12) {
                        MetricPill(label: String(localized: "stats.directoryItems"), value: topic.directoryItemCount)
                        MetricPill(label: String(localized: "stats.inheritors"), value: topic.inheritorCount)
                        MetricPill(label: String(localized: "stats.total"), value: topic.total)
                    }
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Metric Pill

private struct MetricPill: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(HeritageTypography.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme.primary)
            Text(label)
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(colorScheme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Taxonomy Kind List

private struct TaxonomyKindList: View {
    let kinds: [TaxonomyKindDTO]
    let onKindClick: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(kinds.enumerated()), id: \.offset) { _, kind in
                    TaxonomyKindCard(kind: kind) {
                        if let key = kind.key {
                            onKindClick(key)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .padding(.bottom, 18)
        }
    }
}

private struct TaxonomyKindCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let kind: TaxonomyKindDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            ContentCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text(kind.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)

                    HStack(spacing: 12) {
                        MetricPill(label: String(localized: "stats.directoryItems"), value: kind.directoryItemCount)
                        MetricPill(label: String(localized: "stats.inheritors"), value: kind.inheritorCount)
                        MetricPill(label: String(localized: "stats.total"), value: kind.total)
                    }
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Navigation Helpers

struct CompareNavigation: Hashable {
    let type: String
    let left: String
}

#Preview {
    NavigationStack {
        TaxonomyView()
    }
    .heritageTheme()
}
