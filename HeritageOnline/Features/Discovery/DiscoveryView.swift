import SwiftUI

/// 发现页主视图
/// 对齐 Android DiscoveryScreen
/// 实现今日发现、趋势、本周精选、探索主题、学习路径、精选合集等区块
struct DiscoveryView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel = DiscoveryViewModel()

    // 导航状态
    @State private var searchQuery = ""
    @State private var navigateToSearch = false
    @State private var navigateToTopic: ExploreTopicInfoDTO?
    @State private var navigateToLearningPath: LearningPathDTO?
    @State private var navigateToCollection: FeaturedCollectionDTO?
    @State private var navigateToRegionAtlas = false
    @State private var navigateToTimeline = false
    @State private var navigateToTaxonomy = false
    @State private var navigateToStories = false
    @State private var navigateToDeepDive: DiscoveryItemDTO?
    @State private var navigateToArticleDetail: String?
    @State private var navigateToDirectoryDetail: String?
    @State private var navigateToInheritorDetail: String?

    var body: some View {
        PageBackground {
            ZStack {
                // 全页 loading：所有区块都在加载且没有任何数据
                if viewModel.uiState.isAnyLoading &&
                    !viewModel.uiState.today.hasData &&
                    !viewModel.uiState.trending.hasData &&
                    !viewModel.uiState.weekly.hasData &&
                    !viewModel.uiState.classic.hasData {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.uiState.isAllFailed {
                    // 全页错误
                    DiscoveryErrorContent(
                        error: viewModel.uiState.today.error ?? .unknown(nil),
                        onRetry: { viewModel.loadAll() }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 正常内容
                    DiscoveryContent(
                        uiState: viewModel.uiState,
                        onRefresh: { viewModel.loadAll() },
                        onSearchSubmit: { query in
                            searchQuery = query
                            navigateToSearch = true
                        },
                        onTopicClick: { topic in
                            navigateToTopic = topic
                        },
                        onLearningPathClick: { path in
                            navigateToLearningPath = path
                        },
                        onCollectionClick: { collection in
                            navigateToCollection = collection
                        },
                        onRegionAtlasClick: {
                            navigateToRegionAtlas = true
                        },
                        onTimelineClick: {
                            navigateToTimeline = true
                        },
                        onSerendipityClick: {
                            viewModel.serendipity()
                        },
                        onTrendingItemClick: { item in
                            handleItemClick(item)
                        },
                        onWeeklyItemClick: { item in
                            handleItemClick(item)
                        },
                        onTodayItemClick: { item in
                            handleItemClick(item)
                        },
                        onDeepDiveClick: { item in
                            navigateToDeepDive = item
                        },
                        onTaxonomyClick: {
                            navigateToTaxonomy = true
                        },
                        onStoriesClick: {
                            navigateToStories = true
                        },
                        onRetryToday: { viewModel.loadToday() },
                        onRetryTrending: { viewModel.loadTrending() },
                        onRetryWeekly: { viewModel.loadWeekly() },
                        onRetryClassic: { viewModel.loadClassic() }
                    )
                }
            }
        }
        .navigationTitle("tab.discovery")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            viewModel.loadAll()
        }
        .navigationDestination(isPresented: $navigateToSearch) {
            SearchView(
                initialQuery: searchQuery,
                onBack: { navigateToSearch = false },
                onArticleSelected: { id in
                    navigateToSearch = false
                    navigateToArticleDetail = id
                },
                onDirectoryItemSelected: { id in
                    navigateToSearch = false
                    navigateToDirectoryDetail = id
                },
                onInheritorSelected: { id in
                    navigateToSearch = false
                    navigateToInheritorDetail = id
                }
            )
        }
        .navigationDestination(item: $navigateToTopic) { topic in
            ExploreTopicView(type: topic.type ?? "", key: topic.key ?? "")
        }
        .navigationDestination(item: $navigateToLearningPath) { path in
            LearningPathView(id: path.id ?? "")
        }
        .navigationDestination(item: $navigateToCollection) { collection in
            PlaceholderDetailView(titleKey: "contentType.collection")
        }
        .navigationDestination(isPresented: $navigateToRegionAtlas) {
            RegionAtlasView()
        }
        .navigationDestination(isPresented: $navigateToTimeline) {
            TimelineView()
        }
        .navigationDestination(isPresented: $navigateToTaxonomy) {
            PlaceholderDetailView(titleKey: "page.taxonomy")
        }
        .navigationDestination(isPresented: $navigateToStories) {
            PlaceholderDetailView(titleKey: "page.stories")
        }
        .navigationDestination(item: $navigateToDeepDive) { item in
            PlaceholderDetailView(titleKey: "discovery.deepDive")
        }
        .navigationDestination(item: $navigateToArticleDetail) { title in
            PlaceholderDetailView(titleKey: "contentType.article", subtitleKey: LocalizedStringKey(title))
        }
        .navigationDestination(item: $navigateToDirectoryDetail) { title in
            PlaceholderDetailView(titleKey: "contentType.directoryItem", subtitleKey: LocalizedStringKey(title))
        }
        .navigationDestination(item: $navigateToInheritorDetail) { title in
            PlaceholderDetailView(titleKey: "contentType.inheritor", subtitleKey: LocalizedStringKey(title))
        }
    }

    /// 处理内容项点击
    private func handleItemClick(_ item: DiscoveryItemDTO) {
        switch item.type {
        case "article":
            navigateToArticleDetail = item.title
        case "directoryItem":
            navigateToDirectoryDetail = item.title
        case "inheritor":
            navigateToInheritorDetail = item.title
        default:
            break
        }
    }
}

// MARK: - Discovery Content

/// 发现页内容
private struct DiscoveryContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let uiState: DiscoveryUiState
    let onRefresh: () -> Void
    let onSearchSubmit: (String) -> Void
    let onTopicClick: (ExploreTopicInfoDTO) -> Void
    let onLearningPathClick: (LearningPathDTO) -> Void
    let onCollectionClick: (FeaturedCollectionDTO) -> Void
    let onRegionAtlasClick: () -> Void
    let onTimelineClick: () -> Void
    let onSerendipityClick: () -> Void
    let onTrendingItemClick: (DiscoveryItemDTO) -> Void
    let onWeeklyItemClick: (DiscoveryItemDTO) -> Void
    let onTodayItemClick: (DiscoveryItemDTO) -> Void
    let onDeepDiveClick: (DiscoveryItemDTO) -> Void
    let onTaxonomyClick: () -> Void
    let onStoriesClick: () -> Void
    let onRetryToday: () -> Void
    let onRetryTrending: () -> Void
    let onRetryWeekly: () -> Void
    let onRetryClassic: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Header
                DiscoveryHeader(onRefresh: onRefresh)

                // 搜索框
                DiscoverySearchBar(onSearchSubmit: onSearchSubmit)

                // 随便看看按钮
                SerendipityButton(
                    isLoading: uiState.serendipityLoading,
                    onClick: onSerendipityClick
                )

                // 随便看看结果
                if let serendipityItem = uiState.serendipityItem {
                    SerendipityResultCard(
                        item: serendipityItem,
                        onItemClick: onTodayItemClick,
                        onDeepDiveClick: onDeepDiveClick
                    )
                    .padding(.horizontal, 16)
                }

                // 今日发现
                SectionContainer(
                    section: uiState.today,
                    onRetry: onRetryToday,
                    loadingContent: { SectionLoadingPlaceholder() },
                    errorContent: { error in SectionErrorRow(error: error, onRetry: onRetryToday) },
                    content: { today in
                        TodaySection(today: today, onItemClick: onTodayItemClick)
                    }
                )

                // 正在被看见 Trending
                SectionContainer(
                    section: uiState.trending,
                    onRetry: onRetryTrending,
                    loadingContent: { SectionLoadingPlaceholder() },
                    errorContent: { error in SectionErrorRow(error: error, onRetry: onRetryTrending) },
                    content: { trending in
                        if !trending.items.isEmpty {
                            TrendingSection(trending: trending, onItemClick: onTrendingItemClick)
                        }
                    }
                )

                // 本周非遗包 Weekly
                SectionContainer(
                    section: uiState.weekly,
                    onRetry: onRetryWeekly,
                    loadingContent: { SectionLoadingPlaceholder() },
                    errorContent: { error in SectionErrorRow(error: error, onRetry: onRetryWeekly) },
                    content: { weekly in
                        if !weekly.sections.isEmpty {
                            WeeklySection(weekly: weekly, onItemClick: onWeeklyItemClick)
                        }
                    }
                )

                // 主题库入口
                DiscoveryEntryCard(
                    title: String(localized: "discovery.taxonomy"),
                    subtitle: String(localized: "page.taxonomy"),
                    containerColor: colorScheme.tertiaryContainer,
                    onClick: onTaxonomyClick
                )
                .padding(.horizontal, 16)

                // 数据故事入口
                DiscoveryEntryCard(
                    title: String(localized: "discovery.stories"),
                    subtitle: String(localized: "page.stories"),
                    containerColor: colorScheme.primaryContainer,
                    onClick: onStoriesClick
                )
                .padding(.horizontal, 16)

                // 经典区块
                SectionContainer(
                    section: uiState.classic,
                    onRetry: onRetryClassic,
                    loadingContent: { SectionLoadingPlaceholder() },
                    errorContent: { error in SectionErrorRow(error: error, onRetry: onRetryClassic) },
                    content: { classic in
                        ClassicSections(
                            classic: classic,
                            onTopicClick: onTopicClick,
                            onLearningPathClick: onLearningPathClick,
                            onCollectionClick: onCollectionClick,
                            onRegionAtlasClick: onRegionAtlasClick
                        )
                    }
                )

                // 时间线入口
                TimelineCard(onClick: onTimelineClick)
                    .padding(.horizontal, 16)

                // 底部间距
                Spacer()
                    .frame(height: 18)
            }
        }
    }
}

// MARK: - Header

private struct DiscoveryHeader: View {
    let onRefresh: () -> Void

    var body: some View {
        PageHeader(
            titleKey: "page.discovery",
            subtitleKey: "page.discovery.subtitle",
            actions: [
                .init(
                    icon: "arrow.clockwise",
                    accessibilityLabelKey: "action.refresh",
                    action: onRefresh
                )
            ]
        )
    }
}

// MARK: - Search Bar

private struct DiscoverySearchBar: View {
    let onSearchSubmit: (String) -> Void
    @State private var searchText = ""

    var body: some View {
        SearchField(
            text: $searchText,
            placeholder: "discovery.searchPlaceholder",
            onSubmit: {
                if !searchText.isEmpty {
                    onSearchSubmit(searchText)
                }
            }
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Serendipity Button

private struct SerendipityButton: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let isLoading: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Text(isLoading ? String(localized: "loading.exploring") : String(localized: "discovery.serendipity"))
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.onSecondaryContainer)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(colorScheme.secondaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(isLoading)
        .padding(.horizontal, 16)
    }
}

// MARK: - Serendipity Result Card

private struct SerendipityResultCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let item: DiscoveryItemDTO
    let onItemClick: (DiscoveryItemDTO) -> Void
    let onDeepDiveClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        Button(action: { onItemClick(item) }) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "discovery.serendipity"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)

                Text(item.title)
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.bold)
                    .foregroundStyle(colorScheme.onSurface)

                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(3)
                }

                HStack(spacing: 8) {
                    if let category = item.category, !category.isEmpty {
                        MetaChip(category)
                    }
                    if let region = item.region, !region.isEmpty {
                        MetaChip(region)
                    }
                }

                Button(action: { onDeepDiveClick(item) }) {
                    Text(String(localized: "discovery.deepDive"))
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.primary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Today Section

private struct TodaySection: View {
    let today: DiscoveryTodayDTO
    let onItemClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.today"))

            if let featuredDirectoryItem = today.featuredDirectoryItem {
                DiscoveryItemRow(
                    item: featuredDirectoryItem,
                    onClick: { onItemClick(featuredDirectoryItem) }
                )
                .padding(.horizontal, 16)
            }

            if let featuredInheritor = today.featuredInheritor {
                DiscoveryItemRow(
                    item: featuredInheritor,
                    onClick: { onItemClick(featuredInheritor) }
                )
                .padding(.horizontal, 16)
            }

            if !today.articles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(today.articles, id: \.id) { article in
                            DiscoveryItemCard(
                                item: article,
                                onClick: { onItemClick(article) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// MARK: - Trending Section

private struct TrendingSection: View {
    let trending: DiscoveryTrendingDTO
    let onItemClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.trending"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(trending.items, id: \.id) { item in
                        DiscoveryItemCard(
                            item: item,
                            onClick: { onItemClick(item) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Weekly Section

private struct WeeklySection: View {
    let weekly: DiscoveryWeeklyDTO
    let onItemClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.weekly"))

            ForEach(weekly.sections.prefix(2), id: \.id) { section in
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)

                    if let subtitle = section.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(section.items.prefix(5), id: \.id) { item in
                                DiscoveryItemCard(
                                    item: item,
                                    onClick: { onItemClick(item) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Classic Sections

private struct ClassicSections: View {
    let classic: DiscoveryClassicData
    let onTopicClick: (ExploreTopicInfoDTO) -> Void
    let onLearningPathClick: (LearningPathDTO) -> Void
    let onCollectionClick: (FeaturedCollectionDTO) -> Void
    let onRegionAtlasClick: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 探索主题
            if !classic.topics.isEmpty {
                ExploreTopicsSection(
                    topics: classic.topics,
                    onTopicClick: onTopicClick
                )
            }

            // 学习路径
            if !classic.learningPaths.isEmpty {
                LearningPathsSection(
                    paths: classic.learningPaths,
                    onPathClick: onLearningPathClick
                )
            }

            // 精选合集
            if !classic.featuredCollections.isEmpty {
                FeaturedCollectionsSection(
                    collections: classic.featuredCollections,
                    onCollectionClick: onCollectionClick
                )
            }

            // 地区图谱
            if let atlas = classic.regionAtlas {
                RegionAtlasCard(
                    atlas: atlas,
                    onClick: onRegionAtlasClick
                )
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Explore Topics Section

private struct ExploreTopicsSection: View {
    let topics: [ExploreTopicInfoDTO]
    let onTopicClick: (ExploreTopicInfoDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.topics"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(topics, id: \.key) { topic in
                        Button(action: { onTopicClick(topic) }) {
                            Text(topic.title ?? topic.key ?? "")
                                .font(HeritageTypography.labelLarge)
                                .lineLimit(1)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Learning Paths Section

private struct LearningPathsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let paths: [LearningPathDTO]
    let onPathClick: (LearningPathDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.learningPaths"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(paths.enumerated()), id: \.offset) { _, path in
                        LearningPathCard(
                            path: path,
                            onClick: { onPathClick(path) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct LearningPathCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let path: LearningPathDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(path.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                if let subtitle = path.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                }

                Text(String(format: String(localized: "discovery.stepCount %lld"), path.stepCount))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(12)
            .frame(width: 200, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Featured Collections Section

private struct FeaturedCollectionsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collections: [FeaturedCollectionDTO]
    let onCollectionClick: (FeaturedCollectionDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.collections"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(collections.enumerated()), id: \.offset) { _, collection in
                        FeaturedCollectionCard(
                            collection: collection,
                            onClick: { onCollectionClick(collection) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct FeaturedCollectionCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collection: FeaturedCollectionDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                if let subtitle = collection.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                }

                Text(String(format: String(localized: "discovery.itemCount %lld"), collection.itemCount))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(12)
            .frame(width: 180, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Region Atlas Card

private struct RegionAtlasCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let atlas: RegionAtlasDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "discovery.regionAtlas"))
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onPrimaryContainer)

                    Text(String(format: String(localized: "discovery.regionCount %lld"), atlas.totals?.regionCount ?? 0))
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onPrimaryContainer)
                }

                Spacer()

                Text(String(localized: "action.viewDetail"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(16)
            .background(colorScheme.primaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Timeline Card

private struct TimelineCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "discovery.timeline"))
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onSecondaryContainer)

                    Text(String(localized: "discovery.timeline.subtitle"))
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSecondaryContainer)
                }

                Spacer()

                Text(String(localized: "action.viewDetail"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(16)
            .background(colorScheme.secondaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Discovery Entry Card

private struct DiscoveryEntryCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let title: String
    let subtitle: String
    let containerColor: Color
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onSurface)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text(String(localized: "action.viewDetail"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(16)
            .background(containerColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Container

private struct SectionContainer<T>: View {
    let section: DiscoverySectionState<T>
    let onRetry: () -> Void
    let loadingContent: () -> AnyView
    let errorContent: (AppError) -> AnyView
    let content: (T) -> AnyView

    init(
        section: DiscoverySectionState<T>,
        onRetry: @escaping () -> Void,
        @ViewBuilder loadingContent: @escaping () -> some View,
        @ViewBuilder errorContent: @escaping (AppError) -> some View,
        @ViewBuilder content: @escaping (T) -> some View
    ) {
        self.section = section
        self.onRetry = onRetry
        self.loadingContent = { AnyView(loadingContent()) }
        self.errorContent = { error in AnyView(errorContent(error)) }
        self.content = { data in AnyView(content(data)) }
    }

    var body: some View {
        VStack {
            if section.isLoading && !section.hasData {
                loadingContent()
            } else if let error = section.error, section.hasError {
                errorContent(error)
            } else if let data = section.data {
                content(data)
            }
        }
    }
}

// MARK: - Section Loading Placeholder

private struct SectionLoadingPlaceholder: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        Text(String(localized: "loading.default"))
            .font(HeritageTypography.bodyMedium)
            .foregroundStyle(colorScheme.onSurfaceVariant)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
    }
}

// MARK: - Section Error Row

private struct SectionErrorRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        HStack {
            Text(error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Spacer()

            Button(action: onRetry) {
                Text(String(localized: "action.retry"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
        }
        .padding(14)
        .background(colorScheme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}

// MARK: - Discovery Error Content

private struct DiscoveryErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(error.localizedDescription)
                .font(HeritageTypography.bodyLarge)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Button(action: onRetry) {
                Text(String(localized: "action.retry"))
                    .font(HeritageTypography.labelLarge)
            }
            .buttonStyle(.bordered)
        }
        .padding(32)
    }
}

// MARK: - Identifiable Extensions

extension ExploreTopicInfoDTO: Identifiable, Hashable {
    public var id: String { key ?? UUID().uuidString }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ExploreTopicInfoDTO, rhs: ExploreTopicInfoDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension LearningPathDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: LearningPathDTO, rhs: LearningPathDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension FeaturedCollectionDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: FeaturedCollectionDTO, rhs: FeaturedCollectionDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension DiscoveryItemDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DiscoveryItemDTO, rhs: DiscoveryItemDTO) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    NavigationStack {
        DiscoveryView()
    }
    .heritageTheme()
}
