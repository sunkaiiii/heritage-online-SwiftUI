import Foundation

/// Heritage Repository 默认实现
/// 对齐 Android DefaultHeritageRepository，支持详情缓存
/// 详情页先观察缓存，再刷新网络；网络失败但有缓存时显示正文和 stale 提示
@MainActor
final class DefaultHeritageRepository: HeritageRepository {
    private let apiClient: HeritageAPIClient
    private let detailCache: DetailCacheRepository

    init(
        apiClient: HeritageAPIClient = DefaultHeritageAPIClient(),
        detailCache: DetailCacheRepository = DefaultDetailCacheRepository.shared
    ) {
        self.apiClient = apiClient
        self.detailCache = detailCache
    }

    // MARK: - 首页

    func homeBanners() async throws -> [HomeBannerDTO] {
        try await apiClient.getHomeBanners()
    }

    func homeFeed() async throws -> HomeFeedDTO {
        try await apiClient.getHomeFeed()
    }

    // MARK: - 文章

    func articles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO> {
        try await apiClient.getArticles(query: query)
    }

    func article(id: String) async throws -> ArticleDetailDTO {
        try await refreshArticleDetail(ArticleDetailLookup(articleId: id))
    }

    func articleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        try await refreshArticleDetail(ArticleDetailLookup(sourceId: sourceId, category: category))
    }

    func articleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        try await refreshArticleDetail(ArticleDetailLookup(sourceUrl: sourceUrl, category: category))
    }

    func articleContext(id: String) async throws -> DetailContextDTO {
        try await apiClient.getArticleContext(id: id)
    }

    // MARK: - 名录

    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO> {
        try await apiClient.getDirectoryItems(query: query)
    }

    func directoryItem(id: String) async throws -> DirectoryItemDetailDTO {
        try await refreshDirectoryDetail(DirectoryDetailLookup(itemId: id))
    }

    func directoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO {
        try await refreshDirectoryDetail(DirectoryDetailLookup(sourceId: sourceId, kind: kind))
    }

    func directoryItemContext(id: String) async throws -> DetailContextDTO {
        try await apiClient.getDirectoryItemContext(id: id)
    }

    func directoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDTO {
        try await apiClient.getDirectoryStatisticsOverview(kind: kind)
    }

    func directoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDTO {
        try await apiClient.getDirectoryStatisticsBreakdown(kind: kind, dimension: dimension, limit: limit)
    }

    // MARK: - 传承人

    func inheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO> {
        try await apiClient.getInheritors(query: query)
    }

    func inheritor(id: String) async throws -> InheritorDetailDTO {
        try await refreshInheritorDetail(InheritorDetailLookup(inheritorId: id))
    }

    func inheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO {
        try await refreshInheritorDetail(InheritorDetailLookup(sourceId: sourceId))
    }

    func inheritorContext(id: String) async throws -> DetailContextDTO {
        try await apiClient.getInheritorContext(id: id)
    }

    // MARK: - 搜索

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        try await apiClient.searchV2(query: query)
    }

    func searchSuggestions(prefix: String, limit: Int = 10) async throws -> [SearchSuggestionDTO] {
        try await apiClient.getSearchSuggestions(prefix: prefix, limit: limit)
    }

    // MARK: - 时间线

    func timelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        try await apiClient.getTimelineV2(query: query)
    }

    func timelineYears() async throws -> [TimelineYearBucketDTO] {
        try await apiClient.getTimelineYears()
    }

    // MARK: - 发现

    func discoveryToday() async throws -> DiscoveryTodayDTO {
        try await apiClient.getDiscoveryToday()
    }

    func discoveryRandom(type: SearchResultType) async throws -> DiscoveryItemDTO {
        try await apiClient.getDiscoveryRandom(type: type)
    }

    func discoveryTrending(limit: Int = 10) async throws -> DiscoveryTrendingDTO {
        try await apiClient.getDiscoveryTrending(limit: limit)
    }

    func discoveryWeekly() async throws -> DiscoveryWeeklyDTO {
        try await apiClient.getDiscoveryWeekly()
    }

    func discoverySerendipity(query: DiscoverySerendipityQuery) async throws -> DiscoveryItemDTO {
        try await apiClient.getDiscoverySerendipity(query: query)
    }

    func discoveryDeepDive(query: DiscoveryDeepDiveQuery) async throws -> DiscoveryDeepDiveDTO {
        try await apiClient.getDiscoveryDeepDive(query: query)
    }

    // MARK: - 探索

    func exploreIndex() async throws -> ExploreIndexDTO {
        try await apiClient.getExploreIndex()
    }

    func exploreTopics(type: String? = nil, limit: Int = 20) async throws -> [ExploreTopicInfoDTO] {
        try await apiClient.getExploreTopics(type: type, limit: limit)
    }

    func exploreTopic(type: String, key: String, limit: Int = 6) async throws -> ExploreTopicV2DTO {
        try await apiClient.getExploreTopic(type: type, key: key, limit: limit)
    }

    func learningPaths() async throws -> [LearningPathDTO] {
        try await apiClient.getLearningPaths()
    }

    func learningPathDetail(id: String, limit: Int = 6) async throws -> LearningPathDetailDTO {
        try await apiClient.getLearningPathDetail(id: id, limit: limit)
    }

    // MARK: - 地区图谱

    func regionAtlas() async throws -> RegionAtlasDTO {
        try await apiClient.getRegionAtlas()
    }

    func regionAtlasDetail(region: String, limit: Int = 6) async throws -> RegionAtlasDetailDTO {
        try await apiClient.getRegionAtlasDetail(region: region, limit: limit)
    }

    // MARK: - 合集

    func featuredCollections() async throws -> [FeaturedCollectionDTO] {
        try await apiClient.getFeaturedCollections()
    }

    func collection(id: String) async throws -> CollectionDTO {
        try await apiClient.getCollection(id: id)
    }

    func topicCollection(type: String, key: String) async throws -> CollectionDTO {
        try await apiClient.getTopicCollection(type: type, key: key)
    }

    // MARK: - Digest

    func articleDigest(id: String) async throws -> ContentDigestDTO {
        try await apiClient.getArticleDigest(id: id)
    }

    func directoryItemDigest(id: String) async throws -> ContentDigestDTO {
        try await apiClient.getDirectoryItemDigest(id: id)
    }

    func inheritorDigest(id: String) async throws -> ContentDigestDTO {
        try await apiClient.getInheritorDigest(id: id)
    }

    // MARK: - 综合推荐

    func blendedRecommendations(query: BlendedRecommendationQuery) async throws -> BlendedRecommendationResponseDTO {
        try await apiClient.getBlendedRecommendations(query: query)
    }

    // MARK: - 数据故事

    func regionStory(region: String) async throws -> DataStoryDTO {
        try await apiClient.getRegionStory(region: region)
    }

    func categoryStory(category: String) async throws -> DataStoryDTO {
        try await apiClient.getCategoryStory(category: category)
    }

    func yearStory(year: Int) async throws -> DataStoryDTO {
        try await apiClient.getYearStory(year: year)
    }

    // MARK: - 主题库

    func taxonomyCategories(limit: Int = 50) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        try await apiClient.getTaxonomyCategories(limit: limit)
    }

    func taxonomyRegions(limit: Int = 50, sort: TaxonomyRegionSort = .total) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        try await apiClient.getTaxonomyRegions(limit: limit, sort: sort)
    }

    func taxonomyKinds() async throws -> TaxonomyIndexDTO<TaxonomyKindDTO> {
        try await apiClient.getTaxonomyKinds()
    }

    func taxonomyCategoryDetail(category: String, limit: Int = 6) async throws -> TaxonomyCategoryDetailDTO {
        try await apiClient.getTaxonomyCategoryDetail(category: category, limit: limit)
    }

    func taxonomyRegionDetail(region: String, limit: Int = 6) async throws -> TaxonomyRegionDetailDTO {
        try await apiClient.getTaxonomyRegionDetail(region: region, limit: limit)
    }

    // MARK: - 对比

    func compareRegions(left: String, right: String, limit: Int = 6) async throws -> CompareResultDTO {
        try await apiClient.compareRegions(left: left, right: right, limit: limit)
    }

    func compareCategories(left: String, right: String, limit: Int = 6) async throws -> CompareResultDTO {
        try await apiClient.compareCategories(left: left, right: right, limit: limit)
    }

    func compareKinds(left: DirectoryItemKind, right: DirectoryItemKind, limit: Int = 6) async throws -> CompareResultDTO {
        try await apiClient.compareKinds(left: left, right: right, limit: limit)
    }

    // MARK: - Lookup（详情查找）

    func article(lookup: ArticleDetailLookup) async throws -> ArticleDetailDTO {
        let result: ArticleDetailDTO
        if let articleId = lookup.articleId, !articleId.isEmpty {
            result = try await apiClient.getArticle(id: articleId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            result = try await apiClient.getArticleBySourceId(sourceId: sourceId, category: lookup.category)
        } else if let sourceUrl = lookup.sourceUrl, !sourceUrl.isEmpty {
            result = try await apiClient.getArticleBySourceUrl(sourceUrl: sourceUrl, category: lookup.category)
        } else {
            throw NetworkError.badRequest
        }
        // 写入缓存
        await detailCache.cacheArticle(result, lookup: lookup)
        return result
    }

    func directoryItem(lookup: DirectoryDetailLookup) async throws -> DirectoryItemDetailDTO {
        let result: DirectoryItemDetailDTO
        if let itemId = lookup.itemId, !itemId.isEmpty {
            result = try await apiClient.getDirectoryItem(id: itemId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            result = try await apiClient.getDirectoryItemBySourceId(sourceId: sourceId, kind: lookup.kind)
        } else {
            throw NetworkError.badRequest
        }
        // 写入缓存
        await detailCache.cacheDirectoryItem(result, lookup: lookup)
        return result
    }

    func inheritor(lookup: InheritorDetailLookup) async throws -> InheritorDetailDTO {
        let result: InheritorDetailDTO
        if let inheritorId = lookup.inheritorId, !inheritorId.isEmpty {
            result = try await apiClient.getInheritor(id: inheritorId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            result = try await apiClient.getInheritorBySourceId(sourceId: sourceId)
        } else {
            throw NetworkError.badRequest
        }
        // 写入缓存
        await detailCache.cacheInheritor(result, lookup: lookup)
        return result
    }

    // MARK: - 详情缓存读取

    /// 从缓存读取文章详情
    /// 优先级：articleId -> sourceId -> sourceUrl
    func cachedArticleDetail(lookup: ArticleDetailLookup) async -> ArticleDetailDTO? {
        if let articleId = lookup.articleId, !articleId.isEmpty {
            return await detailCache.cachedArticle(id: articleId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return await detailCache.cachedArticleBySourceId(sourceId: sourceId, category: lookup.category.rawValue)
        } else if let sourceUrl = lookup.sourceUrl, !sourceUrl.isEmpty {
            return await detailCache.cachedArticleBySourceUrl(sourceUrl: sourceUrl, category: lookup.category.rawValue)
        }
        return nil
    }

    /// 从缓存读取名录详情
    /// 优先级：itemId -> sourceId
    func cachedDirectoryDetail(lookup: DirectoryDetailLookup) async -> DirectoryItemDetailDTO? {
        if let itemId = lookup.itemId, !itemId.isEmpty {
            return await detailCache.cachedDirectoryItem(id: itemId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return await detailCache.cachedDirectoryItemBySourceId(sourceId: sourceId, kind: lookup.kind.rawValue)
        }
        return nil
    }

    /// 从缓存读取传承人详情
    /// 优先级：inheritorId -> sourceId
    func cachedInheritorDetail(lookup: InheritorDetailLookup) async -> InheritorDetailDTO? {
        if let inheritorId = lookup.inheritorId, !inheritorId.isEmpty {
            return await detailCache.cachedInheritor(id: inheritorId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return await detailCache.cachedInheritorBySourceId(sourceId: sourceId)
        }
        return nil
    }

    // MARK: - 详情刷新（网络请求 + 写入缓存）

    /// 刷新文章详情
    /// 刷新成功后统一写入缓存；界面再从缓存拿到同一份数据，
    /// 这样在线、离线和重试路径的状态来源是一致的。
    private func refreshArticleDetail(_ lookup: ArticleDetailLookup) async throws -> ArticleDetailDTO {
        let article: ArticleDetailDTO
        if let articleId = lookup.articleId, !articleId.isEmpty {
            article = try await apiClient.getArticle(id: articleId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            article = try await apiClient.getArticleBySourceId(sourceId: sourceId, category: lookup.category)
        } else if let sourceUrl = lookup.sourceUrl, !sourceUrl.isEmpty {
            article = try await apiClient.getArticleBySourceUrl(sourceUrl: sourceUrl, category: lookup.category)
        } else {
            throw NetworkError.badRequest
        }

        await detailCache.cacheArticle(article, lookup: lookup)
        return article
    }

    /// 刷新名录详情
    private func refreshDirectoryDetail(_ lookup: DirectoryDetailLookup) async throws -> DirectoryItemDetailDTO {
        let item: DirectoryItemDetailDTO
        if let itemId = lookup.itemId, !itemId.isEmpty {
            item = try await apiClient.getDirectoryItem(id: itemId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            item = try await apiClient.getDirectoryItemBySourceId(sourceId: sourceId, kind: lookup.kind)
        } else {
            throw NetworkError.badRequest
        }

        await detailCache.cacheDirectoryItem(item, lookup: lookup)
        return item
    }

    /// 刷新传承人详情
    private func refreshInheritorDetail(_ lookup: InheritorDetailLookup) async throws -> InheritorDetailDTO {
        let item: InheritorDetailDTO
        if let inheritorId = lookup.inheritorId, !inheritorId.isEmpty {
            item = try await apiClient.getInheritor(id: inheritorId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            item = try await apiClient.getInheritorBySourceId(sourceId: sourceId)
        } else {
            throw NetworkError.badRequest
        }

        await detailCache.cacheInheritor(item, lookup: lookup)
        return item
    }
}
