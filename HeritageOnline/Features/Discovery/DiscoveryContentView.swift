import SwiftUI

/// 发现页内容
struct DiscoveryContent: View {
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
        ScrollView(.vertical, showsIndicators: true) {

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

