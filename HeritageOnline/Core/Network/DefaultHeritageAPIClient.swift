import Foundation

/// Heritage API 客户端默认实现
/// 使用 URLSession 进行网络请求
final class DefaultHeritageAPIClient: HeritageAPIClient {
    private let httpClient: HeritageHTTPClient

    init(httpClient: HeritageHTTPClient = .shared) {
        self.httpClient = httpClient
    }

    // MARK: - 首页

    func getHomeBanners() async throws -> [HomeBannerDTO] {
        try await httpClient.get("api/home-banners")
    }

    func getHomeFeed() async throws -> HomeFeedDTO {
        try await httpClient.get("api/home/feed")
    }

    // MARK: - 文章

    func getArticles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO> {
        var builder = QueryBuilder()
        builder.add("category", value: query.category.wireName)
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("year", value: query.year)
        builder.add("keywords", value: query.keywords)
        return try await httpClient.get("api/articles", queryItems: builder.build())
    }

    func getArticle(id: String) async throws -> ArticleDetailDTO {
        try await httpClient.get(["api", "articles", id])
    }

    func getArticleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        var builder = QueryBuilder()
        builder.add("category", value: category.wireName)
        return try await httpClient.get(
            ["api", "articles", "source", sourceId],
            queryItems: builder.build()
        )
    }

    func getArticleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        var builder = QueryBuilder()
        builder.add("category", value: category.wireName)
        builder.add("sourceUrl", value: sourceUrl)
        return try await httpClient.get("api/articles/source", queryItems: builder.build())
    }

    func getArticleContext(id: String) async throws -> DetailContextDTO {
        try await httpClient.get(["api", "articles", id, "context"])
    }

    // MARK: - 名录

    func getDirectoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO> {
        var builder = QueryBuilder()
        builder.add("kind", value: query.kind.wireName)
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("keywords", value: query.keywords)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        builder.add("year", value: query.year)
        builder.add("listType", value: query.listType)
        return try await httpClient.get("api/directory-items", queryItems: builder.build())
    }

    func getDirectoryItem(id: String) async throws -> DirectoryItemDetailDTO {
        try await httpClient.get(["api", "directory-items", id])
    }

    func getDirectoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO {
        var builder = QueryBuilder()
        builder.add("kind", value: kind.wireName)
        return try await httpClient.get(
            ["api", "directory-items", "source", sourceId],
            queryItems: builder.build()
        )
    }

    func getDirectoryItemContext(id: String) async throws -> DetailContextDTO {
        try await httpClient.get(["api", "directory-items", id, "context"])
    }

    func getDirectoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDTO {
        var builder = QueryBuilder()
        builder.add("kind", value: kind.wireName)
        return try await httpClient.get("api/directory-items/statistics", queryItems: builder.build())
    }

    func getDirectoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDTO {
        var builder = QueryBuilder()
        builder.add("kind", value: kind.wireName)
        builder.add("dimension", value: dimension.wireName)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/directory-items/statistics/breakdown", queryItems: builder.build())
    }

    // MARK: - 传承人

    func getInheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO> {
        var builder = QueryBuilder()
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("keywords", value: query.keywords)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        builder.add("year", value: query.year)
        builder.add("gender", value: query.gender)
        return try await httpClient.get("api/inheritors", queryItems: builder.build())
    }

    func getInheritor(id: String) async throws -> InheritorDetailDTO {
        try await httpClient.get(["api", "inheritors", id])
    }

    func getInheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO {
        try await httpClient.get(["api", "inheritors", "source", sourceId])
    }

    func getInheritorContext(id: String) async throws -> DetailContextDTO {
        try await httpClient.get(["api", "inheritors", id, "context"])
    }

    // MARK: - 搜索

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        var builder = QueryBuilder()
        builder.add("keywords", value: query.keywords)
        builder.add("types", values: query.types.map { $0.wireName })
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        builder.add("year", value: query.year)
        builder.add("kind", value: query.kind?.wireName)
        builder.add("hasImage", value: query.hasImage)
        return try await httpClient.get("api/search/v2", queryItems: builder.build())
    }

    func getSearchSuggestions(prefix: String, limit: Int = 10) async throws -> [SearchSuggestionDTO] {
        var builder = QueryBuilder()
        builder.add("prefix", value: prefix)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/search/suggestions", queryItems: builder.build())
    }

    // MARK: - 时间线

    func getTimelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        var builder = QueryBuilder()
        builder.add("year", value: query.year)
        builder.add("types", values: query.types.map { $0.wireName })
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("category", value: query.category)
        builder.add("region", value: query.region)
        builder.add("kind", value: query.kind?.wireName)
        builder.add("hasImage", value: query.hasImage)
        return try await httpClient.get("api/timeline/v2", queryItems: builder.build())
    }

    func getTimelineYears() async throws -> [TimelineYearBucketDTO] {
        try await httpClient.get("api/timeline/years")
    }

    // MARK: - 发现

    func getDiscoveryToday() async throws -> DiscoveryTodayDTO {
        try await httpClient.get("api/discovery/today")
    }

    func getDiscoveryRandom(type: SearchResultType) async throws -> DiscoveryItemDTO {
        var builder = QueryBuilder()
        builder.add("type", value: type.wireName)
        return try await httpClient.get("api/discovery/random", queryItems: builder.build())
    }

    func getDiscoveryTrending(limit: Int = 10) async throws -> DiscoveryTrendingDTO {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get("api/discovery/trending", queryItems: builder.build())
    }

    func getDiscoveryWeekly() async throws -> DiscoveryWeeklyDTO {
        try await httpClient.get("api/discovery/weekly")
    }

    func getDiscoverySerendipity(query: DiscoverySerendipityQuery) async throws -> DiscoveryItemDTO {
        var builder = QueryBuilder()
        builder.add("type", value: query.type.wireName)
        builder.add("hasImage", value: query.hasImage)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        return try await httpClient.get("api/discovery/serendipity", queryItems: builder.build())
    }

    func getDiscoveryDeepDive(query: DiscoveryDeepDiveQuery) async throws -> DiscoveryDeepDiveDTO {
        var builder = QueryBuilder()
        builder.add("seedType", value: query.seedType.wireName)
        builder.add("seedId", value: query.seedId)
        builder.add("limit", value: query.limit)
        return try await httpClient.get("api/discovery/deep-dive", queryItems: builder.build())
    }

    // MARK: - 探索

    func getExploreIndex() async throws -> ExploreIndexDTO {
        try await httpClient.get("api/explore")
    }

    func getExploreTopics(type: String? = nil, limit: Int = 20) async throws -> [ExploreTopicInfoDTO] {
        var builder = QueryBuilder()
        builder.add("type", value: type)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/explore/topics", queryItems: builder.build())
    }

    func getExploreTopic(type: String, key: String, limit: Int = 6) async throws -> ExploreTopicV2DTO {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get(["api", "explore", "topics", type, key], queryItems: builder.build())
    }

    func getLearningPaths() async throws -> [LearningPathDTO] {
        try await httpClient.get("api/explore/learning-paths")
    }

    func getLearningPathDetail(id: String, limit: Int = 6) async throws -> LearningPathDetailDTO {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get(["api", "explore", "learning-paths", id], queryItems: builder.build())
    }

    // MARK: - 地区图谱

    func getRegionAtlas() async throws -> RegionAtlasDTO {
        try await httpClient.get("api/regions/atlas")
    }

    func getRegionAtlasDetail(region: String, limit: Int = 6) async throws -> RegionAtlasDetailDTO {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get(["api", "regions", region, "atlas"], queryItems: builder.build())
    }

    // MARK: - 合集

    func getFeaturedCollections() async throws -> [FeaturedCollectionDTO] {
        try await httpClient.get("api/collections/featured")
    }

    func getCollection(id: String) async throws -> CollectionDTO {
        try await httpClient.get(["api", "collections", id])
    }

    func getTopicCollection(type: String, key: String) async throws -> CollectionDTO {
        try await httpClient.get(["api", "collections", "topic", type, key])
    }

    // MARK: - Digest

    func getArticleDigest(id: String) async throws -> ContentDigestDTO {
        try await httpClient.get(["api", "articles", id, "digest"])
    }

    func getDirectoryItemDigest(id: String) async throws -> ContentDigestDTO {
        try await httpClient.get(["api", "directory-items", id, "digest"])
    }

    func getInheritorDigest(id: String) async throws -> ContentDigestDTO {
        try await httpClient.get(["api", "inheritors", id, "digest"])
    }

    // MARK: - 综合推荐

    func getBlendedRecommendations(query: BlendedRecommendationQuery) async throws -> BlendedRecommendationResponseDTO {
        var builder = QueryBuilder()
        builder.add("limit", value: query.limit)
        builder.add("ruleWeight", value: String(query.ruleWeight))
        builder.add("semanticWeight", value: String(query.semanticWeight))
        builder.add("sameCategoryWeight", value: String(query.sameCategoryWeight))
        builder.add("sameRegionWeight", value: String(query.sameRegionWeight))
        builder.add("diversify", value: query.diversify)
        return try await httpClient.get(["api", "recommendations", "blended", query.type.wireName, query.id], queryItems: builder.build())
    }

    // MARK: - 数据故事

    func getRegionStory(region: String) async throws -> DataStoryDTO {
        try await httpClient.get(["api", "stories", "regions", region])
    }

    func getCategoryStory(category: String) async throws -> DataStoryDTO {
        try await httpClient.get(["api", "stories", "categories", category])
    }

    func getYearStory(year: Int) async throws -> DataStoryDTO {
        try await httpClient.get(["api", "stories", "years", String(year)])
    }

    // MARK: - 主题库

    func getTaxonomyCategories(limit: Int = 50) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get("api/taxonomy/categories", queryItems: builder.build())
    }

    func getTaxonomyRegions(limit: Int = 50, sort: TaxonomyRegionSort = .total) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        builder.add("sort", value: sort.wireName)
        return try await httpClient.get("api/taxonomy/regions", queryItems: builder.build())
    }

    func getTaxonomyKinds() async throws -> TaxonomyIndexDTO<TaxonomyKindDTO> {
        try await httpClient.get("api/taxonomy/kinds")
    }

    func getTaxonomyCategoryDetail(category: String, limit: Int = 6) async throws -> TaxonomyCategoryDetailDTO {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get(["api", "taxonomy", "category", category], queryItems: builder.build())
    }

    func getTaxonomyRegionDetail(region: String, limit: Int = 6) async throws -> TaxonomyRegionDetailDTO {
        var builder = QueryBuilder()
        builder.add("limit", value: limit)
        return try await httpClient.get(["api", "taxonomy", "region", region], queryItems: builder.build())
    }

    // MARK: - 对比

    func compareRegions(left: String, right: String, limit: Int = 6) async throws -> CompareResultDTO {
        var builder = QueryBuilder()
        builder.add("left", value: left)
        builder.add("right", value: right)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/compare/regions", queryItems: builder.build())
    }

    func compareCategories(left: String, right: String, limit: Int = 6) async throws -> CompareResultDTO {
        var builder = QueryBuilder()
        builder.add("left", value: left)
        builder.add("right", value: right)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/compare/categories", queryItems: builder.build())
    }

    func compareKinds(left: DirectoryItemKind, right: DirectoryItemKind, limit: Int = 6) async throws -> CompareResultDTO {
        var builder = QueryBuilder()
        builder.add("left", value: left.wireName)
        builder.add("right", value: right.wireName)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/compare/kinds", queryItems: builder.build())
    }
}
