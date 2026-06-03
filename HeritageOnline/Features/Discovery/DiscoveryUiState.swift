import Foundation

/// 发现页经典区块数据
/// 对齐 Android DiscoveryClassicData
struct DiscoveryClassicData {
    let exploreIndex: ExploreIndexDTO?
    let topics: [ExploreTopicInfoDTO]
    let learningPaths: [LearningPathDTO]
    let featuredCollections: [FeaturedCollectionDTO]
    let regionAtlas: RegionAtlasDTO?

    init(
        exploreIndex: ExploreIndexDTO? = nil,
        topics: [ExploreTopicInfoDTO] = [],
        learningPaths: [LearningPathDTO] = [],
        featuredCollections: [FeaturedCollectionDTO] = [],
        regionAtlas: RegionAtlasDTO? = nil
    ) {
        self.exploreIndex = exploreIndex
        self.topics = topics
        self.learningPaths = learningPaths
        self.featuredCollections = featuredCollections
        self.regionAtlas = regionAtlas
    }
}

/// 发现页 UI 状态
/// 对齐 Android DiscoveryUiState
struct DiscoveryUiState {
    // 发现 v2 区块（高优先级）
    let today: DiscoverySectionState<DiscoveryTodayDTO>
    let trending: DiscoverySectionState<DiscoveryTrendingDTO>
    let weekly: DiscoverySectionState<DiscoveryWeeklyDTO>
    // 经典区块（较低优先级）
    let classic: DiscoverySectionState<DiscoveryClassicData>
    // 随便看看
    let serendipityItem: DiscoveryItemDTO?
    let serendipityLoading: Bool

    init(
        today: DiscoverySectionState<DiscoveryTodayDTO> = DiscoverySectionState(),
        trending: DiscoverySectionState<DiscoveryTrendingDTO> = DiscoverySectionState(),
        weekly: DiscoverySectionState<DiscoveryWeeklyDTO> = DiscoverySectionState(),
        classic: DiscoverySectionState<DiscoveryClassicData> = DiscoverySectionState(),
        serendipityItem: DiscoveryItemDTO? = nil,
        serendipityLoading: Bool = false
    ) {
        self.today = today
        self.trending = trending
        self.weekly = weekly
        self.classic = classic
        self.serendipityItem = serendipityItem
        self.serendipityLoading = serendipityLoading
    }

    /// 是否有任意区块在加载
    var isAnyLoading: Bool {
        today.isLoading || trending.isLoading || weekly.isLoading || classic.isLoading
    }

    /// 是否全部失败
    var isAllFailed: Bool {
        today.hasError && trending.hasError && weekly.hasError && classic.hasError
    }
}
