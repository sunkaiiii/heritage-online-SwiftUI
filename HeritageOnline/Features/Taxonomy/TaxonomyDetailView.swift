import SwiftUI

/// 主题库详情页
/// 对齐 Android TaxonomyDetailScreen
struct TaxonomyDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel: TaxonomyDetailViewModel

    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?
    @State private var navigateToTopic: TopicNavigation?
    @State private var navigateToCollection: String?
    @State private var navigateToStory: StoryNavigation?
    @State private var navigateToCompare: CompareNavigation?

    init(type: String, key: String) {
        _viewModel = State(initialValue: TaxonomyDetailViewModel(type: type, key: key))
    }

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.uiState.isLoading {
                    LoadingPlaceholder()
                } else if let error = viewModel.uiState.error {
                    errorView(error)
                } else if let detail = viewModel.uiState.categoryDetail {
                    CategoryDetailContent(
                        detail: detail,
                        onArticleClick: { navigateToArticle = $0 },
                        onDirectoryClick: { navigateToDirectory = $0 },
                        onInheritorClick: { navigateToInheritor = $0 },
                        onRelatedCategoryClick: { navigateToTopic = TopicNavigation(type: "category", key: $0) },
                        onCollectionClick: { navigateToCollection = $0 },
                        onViewStory: { navigateToStory = StoryNavigation(category: viewModel.topicKey) },
                        onCompare: { navigateToCompare = CompareNavigation(type: "category", left: viewModel.topicKey) }
                    )
                } else if let detail = viewModel.uiState.regionDetail {
                    RegionDetailContent(
                        detail: detail,
                        onArticleClick: { navigateToArticle = $0 },
                        onDirectoryClick: { navigateToDirectory = $0 },
                        onInheritorClick: { navigateToInheritor = $0 },
                        onRelatedRegionClick: { navigateToTopic = TopicNavigation(type: "region", key: $0) },
                        onCollectionClick: { navigateToCollection = $0 },
                        onViewStory: { navigateToStory = StoryNavigation(region: viewModel.topicKey) },
                        onCompare: { navigateToCompare = CompareNavigation(type: "region", left: viewModel.topicKey) }
                    )
                }
            }
        }
        .navigationTitle(viewModel.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .task {
            if viewModel.uiState.categoryDetail == nil && viewModel.uiState.regionDetail == nil && viewModel.uiState.error == nil {
                viewModel.loadDetail()
            }
        }
        .navigationDestination(item: $navigateToArticle) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToDirectory) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToInheritor) { id in
            InheritorDetailView(inheritorId: id)
        }
        .navigationDestination(item: $navigateToTopic) { nav in
            TaxonomyDetailView(type: nav.type, key: nav.key)
        }
        .navigationDestination(item: $navigateToCollection) { id in
            CollectionDetailView(id: id)
        }
        .navigationDestination(item: $navigateToStory) { nav in
            StoryDetailView(region: nav.region, category: nav.category, year: nav.year)
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
            Button("action.retry") { viewModel.loadDetail() }
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Category Detail Content

private struct CategoryDetailContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let detail: TaxonomyCategoryDetailDTO
    let onArticleClick: (String) -> Void
    let onDirectoryClick: (String) -> Void
    let onInheritorClick: (String) -> Void
    let onRelatedCategoryClick: (String) -> Void
    let onCollectionClick: (String) -> Void
    let onViewStory: () -> Void
    let onCompare: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // Header
                if let topic = detail.topic {
                    TaxonomyDetailHeader(topic: topic)
                }

                // Stats
                if let stats = detail.stats {
                    TaxonomyStatsRow(stats: stats)
                }

                // Top Regions
                if !detail.topRegions.isEmpty {
                    TaxonomyChipsSection(
                        title: String(localized: "taxonomy.topRegions"),
                        items: detail.topRegions.map { "\($0.region) (\($0.count))" }
                    )
                }

                // Articles
                if !detail.articles.isEmpty {
                    TaxonomyItemList(
                        title: String(localized: "stats.articles"),
                        items: detail.articles.map { ($0.id ?? "", $0.title ?? "", $0.category) },
                        onItemClick: onArticleClick
                    )
                }

                // Directory Items
                if !detail.directoryItems.isEmpty {
                    TaxonomyItemList(
                        title: String(localized: "stats.directoryItems"),
                        items: detail.directoryItems.map { ($0.id ?? "", $0.title ?? "", $0.category) },
                        onItemClick: onDirectoryClick
                    )
                }

                // Inheritors
                if !detail.inheritors.isEmpty {
                    TaxonomyItemList(
                        title: String(localized: "stats.inheritors"),
                        items: detail.inheritors.map { ($0.id ?? "", $0.name ?? "", $0.category) },
                        onItemClick: onInheritorClick
                    )
                }

                // Related Categories
                if !detail.relatedCategories.isEmpty {
                    TaxonomyChipsSection(
                        title: String(localized: "taxonomy.relatedCategories"),
                        items: detail.relatedCategories,
                        onChipClick: onRelatedCategoryClick
                    )
                }

                // Recommended Collections
                if !detail.recommendedCollections.isEmpty {
                    TaxonomyCollectionsSection(
                        collections: detail.recommendedCollections,
                        onCollectionClick: onCollectionClick
                    )
                }

                // Actions
                TaxonomyActions(onViewStory: onViewStory, onCompare: onCompare)

                Spacer().frame(height: 18)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
    }
}

// MARK: - Region Detail Content

private struct RegionDetailContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let detail: TaxonomyRegionDetailDTO
    let onArticleClick: (String) -> Void
    let onDirectoryClick: (String) -> Void
    let onInheritorClick: (String) -> Void
    let onRelatedRegionClick: (String) -> Void
    let onCollectionClick: (String) -> Void
    let onViewStory: () -> Void
    let onCompare: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // Header
                if let topic = detail.topic {
                    TaxonomyDetailHeader(topic: topic)
                }

                // Stats
                if let stats = detail.stats {
                    TaxonomyStatsRow(stats: stats)
                }

                // Top Categories
                if !detail.topCategories.isEmpty {
                    TaxonomyChipsSection(
                        title: String(localized: "taxonomy.topCategories"),
                        items: detail.topCategories.map { "\($0.category) (\($0.count))" }
                    )
                }

                // Articles
                if !detail.articles.isEmpty {
                    TaxonomyItemList(
                        title: String(localized: "stats.articles"),
                        items: detail.articles.map { ($0.id ?? "", $0.title ?? "", $0.category) },
                        onItemClick: onArticleClick
                    )
                }

                // Directory Items
                if !detail.directoryItems.isEmpty {
                    TaxonomyItemList(
                        title: String(localized: "stats.directoryItems"),
                        items: detail.directoryItems.map { ($0.id ?? "", $0.title ?? "", $0.category) },
                        onItemClick: onDirectoryClick
                    )
                }

                // Inheritors
                if !detail.inheritors.isEmpty {
                    TaxonomyItemList(
                        title: String(localized: "stats.inheritors"),
                        items: detail.inheritors.map { ($0.id ?? "", $0.name ?? "", $0.category) },
                        onItemClick: onInheritorClick
                    )
                }

                // Related Regions
                if !detail.relatedRegions.isEmpty {
                    TaxonomyChipsSection(
                        title: String(localized: "taxonomy.relatedRegions"),
                        items: detail.relatedRegions,
                        onChipClick: onRelatedRegionClick
                    )
                }

                // Recommended Collections
                if !detail.recommendedCollections.isEmpty {
                    TaxonomyCollectionsSection(
                        collections: detail.recommendedCollections,
                        onCollectionClick: onCollectionClick
                    )
                }

                // Actions
                TaxonomyActions(onViewStory: onViewStory, onCompare: onCompare)

                Spacer().frame(height: 18)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
    }
}

// MARK: - Shared Components

private struct TaxonomyDetailHeader: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let topic: TaxonomyTopicDTO

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let typeKey = ContentLabels.exploreTopicTypeKey(topic.type) {
                MetaChip(LocalizedStringKey(typeKey))
            }
            Text(topic.title ?? "")
                .font(HeritageTypography.headlineMedium)
                .foregroundStyle(colorScheme.onSurface)
            if let subtitle = topic.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(HeritageTypography.bodyLarge)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
        }
    }
}

private struct TaxonomyStatsRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let stats: TaxonomyStatDTO

    var body: some View {
        HStack(spacing: 12) {
            StatItem(label: String(localized: "stats.directoryItems"), value: stats.directoryItemCount)
            StatItem(label: String(localized: "stats.inheritors"), value: stats.inheritorCount)
            StatItem(label: String(localized: "stats.articles"), value: stats.articleCount)
            StatItem(label: String(localized: "stats.total"), value: stats.total)
        }
    }
}

private struct StatItem: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(HeritageTypography.titleLarge)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme.primary)
            Text(label)
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(colorScheme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct TaxonomyChipsSection: View {
    let title: String
    let items: [String]
    var onChipClick: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)
            FlowLayout(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    if let onChipClick {
                        Button(action: { onChipClick(item) }) {
                            MetaChip(item)
                        }
                        .buttonStyle(.plain)
                    } else {
                        MetaChip(item)
                    }
                }
            }
        }
    }
}

private struct TaxonomyItemList: View {
    let title: String
    let items: [(id: String, title: String, category: String?)]
    let onItemClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                Button(action: { onItemClick(item.id) }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(HeritageTypography.titleMedium)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                            if let category = item.category, !category.isEmpty {
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
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TaxonomyCollectionsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collections: [CollectionItemDTO]
    let onCollectionClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "context.collections"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(collections.enumerated()), id: \.offset) { _, item in
                        Button(action: {
                            if let id = item.id { onCollectionClick(id) }
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title ?? "")
                                    .font(HeritageTypography.titleMedium)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                    .foregroundStyle(colorScheme.onSurface)
                            }
                            .padding(12)
                            .frame(width: 160, alignment: .leading)
                            .background(colorScheme.surfaceContainerHigh)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct TaxonomyActions: View {
    let onViewStory: () -> Void
    let onCompare: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onViewStory) {
                Label(String(localized: "taxonomy.viewStory"), systemImage: "book")
                    .font(HeritageTypography.labelLarge)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)

            Button(action: onCompare) {
                Label(String(localized: "taxonomy.compare"), systemImage: "arrow.left.arrow.right")
                    .font(HeritageTypography.labelLarge)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Navigation Helpers

struct StoryNavigation: Hashable {
    let region: String?
    let category: String?
    let year: Int?

    init(region: String? = nil, category: String? = nil, year: Int? = nil) {
        self.region = region
        self.category = category
        self.year = year
    }
}

#Preview {
    NavigationStack {
        TaxonomyDetailView(type: "category", key: "传统音乐")
    }
    .heritageTheme()
}
