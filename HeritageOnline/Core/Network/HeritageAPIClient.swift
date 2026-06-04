import Foundation

/// Heritage API 客户端接口
/// 对齐 Android API 合同
protocol HeritageAPIClient: Sendable {
    // MARK: - 首页

    /// 获取首页 Banner
    func getHomeBanners() async throws -> [HomeBannerDTO]

    /// 获取首页 Feed
    func getHomeFeed() async throws -> HomeFeedDTO

    // MARK: - 文章

    /// 获取文章列表
    func getArticles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO>

    /// 获取文章详情
    func getArticle(id: String) async throws -> ArticleDetailDTO

    /// 通过 sourceId 获取文章详情
    func getArticleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO

    /// 通过 sourceUrl 获取文章详情
    func getArticleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO

    /// 获取文章 Context
    func getArticleContext(id: String) async throws -> DetailContextDTO

    // MARK: - 名录

    /// 获取名录列表
    func getDirectoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO>

    /// 获取名录详情
    func getDirectoryItem(id: String) async throws -> DirectoryItemDetailDTO

    /// 通过 sourceId 获取名录详情
    func getDirectoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO

    /// 获取名录 Context
    func getDirectoryItemContext(id: String) async throws -> DetailContextDTO

    /// 获取名录统计总览
    func getDirectoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDTO

    /// 获取名录统计 breakdown
    func getDirectoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDTO

    // MARK: - 传承人

    /// 获取传承人列表
    func getInheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO>

    /// 获取传承人详情
    func getInheritor(id: String) async throws -> InheritorDetailDTO

    /// 通过 sourceId 获取传承人详情
    func getInheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO

    /// 获取传承人 Context
    func getInheritorContext(id: String) async throws -> DetailContextDTO

    // MARK: - 搜索

    /// 搜索 v2
    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO

    /// 获取搜索建议
    func getSearchSuggestions(prefix: String, limit: Int) async throws -> [SearchSuggestionDTO]

    // MARK: - 时间线

    /// 获取时间线
    func getTimelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO

    /// 获取年份聚合
    func getTimelineYears() async throws -> [TimelineYearBucketDTO]

    // MARK: - 发现

    /// 获取今日发现
    func getDiscoveryToday() async throws -> DiscoveryTodayDTO

    /// 获取随机内容
    func getDiscoveryRandom(type: SearchResultType) async throws -> DiscoveryItemDTO

    /// 获取趋势内容
    func getDiscoveryTrending(limit: Int) async throws -> DiscoveryTrendingDTO

    /// 获取本周精选
    func getDiscoveryWeekly() async throws -> DiscoveryWeeklyDTO

    /// 获取随便看看
    func getDiscoverySerendipity(query: DiscoverySerendipityQuery) async throws -> DiscoveryItemDTO

    /// 获取深度探索
    func getDiscoveryDeepDive(query: DiscoveryDeepDiveQuery) async throws -> DiscoveryDeepDiveDTO

    // MARK: - 探索

    /// 获取探索首页
    func getExploreIndex() async throws -> ExploreIndexDTO

    /// 获取探索主题列表
    func getExploreTopics(type: String?, limit: Int) async throws -> [ExploreTopicInfoDTO]

    /// 获取探索主题详情
    func getExploreTopic(type: String, key: String, limit: Int) async throws -> ExploreTopicV2DTO

    /// 获取学习路径列表
    func getLearningPaths() async throws -> [LearningPathDTO]

    /// 获取学习路径详情
    func getLearningPathDetail(id: String, limit: Int) async throws -> LearningPathDetailDTO

    // MARK: - 地区图谱

    /// 获取地区图谱首页
    func getRegionAtlas() async throws -> RegionAtlasDTO

    /// 获取地区图谱详情
    func getRegionAtlasDetail(region: String, limit: Int) async throws -> RegionAtlasDetailDTO

    // MARK: - 合集

    /// 获取精选合集
    func getFeaturedCollections() async throws -> [FeaturedCollectionDTO]

    /// 获取合集详情
    func getCollection(id: String) async throws -> CollectionDTO

    /// 获取主题合集
    func getTopicCollection(type: String, key: String) async throws -> CollectionDTO

    // MARK: - Digest

    /// 获取文章 Digest
    func getArticleDigest(id: String) async throws -> ContentDigestDTO

    /// 获取名录 Digest
    func getDirectoryItemDigest(id: String) async throws -> ContentDigestDTO

    /// 获取传承人 Digest
    func getInheritorDigest(id: String) async throws -> ContentDigestDTO

    // MARK: - 综合推荐

    /// 获取综合推荐
    func getBlendedRecommendations(query: BlendedRecommendationQuery) async throws -> BlendedRecommendationResponseDTO

    // MARK: - 数据故事

    /// 获取地区故事
    func getRegionStory(region: String) async throws -> DataStoryDTO

    /// 获取分类故事
    func getCategoryStory(category: String) async throws -> DataStoryDTO

    /// 获取年份故事
    func getYearStory(year: Int) async throws -> DataStoryDTO

    // MARK: - 主题库

    /// 获取分类索引
    func getTaxonomyCategories(limit: Int) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO>

    /// 获取地区索引
    func getTaxonomyRegions(limit: Int, sort: TaxonomyRegionSort) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO>

    /// 获取种类索引
    func getTaxonomyKinds() async throws -> TaxonomyIndexDTO<TaxonomyKindDTO>

    /// 获取分类详情
    func getTaxonomyCategoryDetail(category: String, limit: Int) async throws -> TaxonomyCategoryDetailDTO

    /// 获取地区详情
    func getTaxonomyRegionDetail(region: String, limit: Int) async throws -> TaxonomyRegionDetailDTO

    // MARK: - 对比

    /// 地区对比
    func compareRegions(left: String, right: String, limit: Int) async throws -> CompareResultDTO

    /// 分类对比
    func compareCategories(left: String, right: String, limit: Int) async throws -> CompareResultDTO

    /// 种类对比
    func compareKinds(left: DirectoryItemKind, right: DirectoryItemKind, limit: Int) async throws -> CompareResultDTO
}

