import Foundation
@testable import HeritageOnline

/// Mock Heritage Repository
/// 用于单元测试，可以替换真实实现
final class MockHeritageRepository: HeritageRepository, @unchecked Sendable {
    // MARK: - Mock 数据

    var homeBannersResult: Result<[HomeBannerDTO], Error> = .success([])
    var homeFeedResult: Result<HomeFeedDTO, Error> = .success(HomeFeedDTO(
        banners: [],
        latestNews: [],
        latestSpecialTopics: [],
        latestForumArticles: [],
        featuredDirectoryItems: [],
        featuredInheritors: [],
        summary: nil
    ))
    var articlesResult: Result<PagedResultDTO<ArticleSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
    )
    var articleResult: Result<ArticleDetailDTO, Error> = .success(ArticleDetailDTO(
        id: "test",
        category: nil,
        title: nil,
        summary: nil,
        publishedAt: nil,
        coverImage: nil,
        sourceUrl: nil,
        sourceName: nil,
        author: nil,
        editor: nil,
        contentBlocks: [],
        relatedArticles: []
    ))
    var directoryItemsResult: Result<PagedResultDTO<DirectoryItemSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
    )
    var directoryItemResult: Result<DirectoryItemDetailDTO, Error> = .success(DirectoryItemDetailDTO(
        id: "test",
        kind: nil,
        title: nil,
        summary: nil,
        category: nil,
        region: nil,
        projectCode: nil,
        batch: nil,
        publishedYear: nil,
        listType: nil,
        nominationType: nil,
        protectionUnit: nil,
        coverImage: nil,
        sourceUrl: nil,
        gallery: [],
        contentBlocks: [],
        relatedProjects: [],
        relatedInheritors: [],
        relatedDocuments: []
    ))
    var inheritorsResult: Result<PagedResultDTO<InheritorSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
    )
    var inheritorResult: Result<InheritorDetailDTO, Error> = .success(InheritorDetailDTO(
        id: "test",
        name: nil,
        gender: nil,
        birthDateText: nil,
        ethnicity: nil,
        category: nil,
        projectCode: nil,
        projectName: nil,
        region: nil,
        batch: nil,
        description: nil,
        coverImage: nil,
        sourceUrl: nil,
        contentBlocks: [],
        relatedProjects: [],
        relatedInheritors: []
    ))
    var searchV2Result: Result<SearchV2ResponseDTO, Error> = .success(
        SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
    )
    var searchSuggestionsResult: Result<[SearchSuggestionDTO], Error> = .success([])
    var timelineV2Result: Result<TimelineV2ResponseDTO, Error> = .success(
        TimelineV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil)
    )
    var timelineYearsResult: Result<[TimelineYearBucketDTO], Error> = .success([])
    var articleContextResult: Result<DetailContextDTO, Error> = .success(DetailContextDTO(
        related: [],
        recommendations: [],
        semanticRecommendations: [],
        collections: [],
        exploreTopics: [],
        graph: []
    ))
    var directoryItemContextResult: Result<DetailContextDTO, Error> = .success(DetailContextDTO(
        related: [],
        recommendations: [],
        semanticRecommendations: [],
        collections: [],
        exploreTopics: [],
        graph: []
    ))
    var inheritorContextResult: Result<DetailContextDTO, Error> = .success(DetailContextDTO(
        related: [],
        recommendations: [],
        semanticRecommendations: [],
        collections: [],
        exploreTopics: [],
        graph: []
    ))
    var directoryStatisticsOverviewResult: Result<DirectoryStatisticsOverviewDTO, Error> = .success(
        DirectoryStatisticsOverviewDTO(kind: nil, total: 0, generatedAt: nil, dimensions: [])
    )
    var directoryStatisticsBreakdownResult: Result<DirectoryStatisticDimensionDTO, Error> = .success(
        DirectoryStatisticDimensionDTO(dimension: nil, items: [])
    )

    // MARK: - Step 18-25 Mock 数据

    var discoveryTodayResult: Result<DiscoveryTodayDTO, Error> = .success(
        DiscoveryTodayDTO(featuredDirectoryItem: nil, featuredInheritor: nil, articles: [], date: "2026-01-01")
    )
    var discoveryRandomResult: Result<DiscoveryItemDTO, Error> = .success(
        DiscoveryItemDTO(id: "test", type: "article", title: "Test", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com")
    )
    var discoveryTrendingResult: Result<DiscoveryTrendingDTO, Error> = .success(
        DiscoveryTrendingDTO(items: [], generatedAt: nil)
    )
    var discoveryWeeklyResult: Result<DiscoveryWeeklyDTO, Error> = .success(
        DiscoveryWeeklyDTO(weekId: "test", sections: [], generatedAt: nil)
    )
    var discoverySerendipityResult: Result<DiscoveryItemDTO, Error> = .success(
        DiscoveryItemDTO(id: "test", type: "article", title: "Test", summary: nil, category: nil, kind: nil, region: nil, publishedAt: nil, publishedYear: nil, coverImage: nil, sourceUrl: "https://example.com")
    )
    var discoveryDeepDiveResult: Result<DiscoveryDeepDiveDTO, Error> = .success(
        DiscoveryDeepDiveDTO(seed: nil, related: [], generatedAt: nil)
    )
    var exploreIndexResult: Result<ExploreIndexDTO, Error> = .success(
        ExploreIndexDTO(regions: [], categories: [], years: [])
    )
    var exploreTopicsResult: Result<[ExploreTopicInfoDTO], Error> = .success([])
    var exploreTopicResult: Result<ExploreTopicV2DTO, Error> = .success(
        ExploreTopicV2DTO(topic: nil, stats: [], sections: [], relatedTopics: [], timeline: [], generatedAt: nil)
    )
    var learningPathsResult: Result<[LearningPathDTO], Error> = .success([])
    var learningPathDetailResult: Result<LearningPathDetailDTO, Error> = .success(
        LearningPathDetailDTO(id: nil, title: nil, subtitle: nil, description: nil, tags: [], steps: [], featuredItems: [], relatedTopics: [], generatedAt: nil)
    )
    var regionAtlasResult: Result<RegionAtlasDTO, Error> = .success(
        RegionAtlasDTO(regions: [], totals: nil, generatedAt: nil)
    )
    var regionAtlasDetailResult: Result<RegionAtlasDetailDTO, Error> = .success(
        MockDTOFactory.regionAtlasDetailDTO()
    )
    var featuredCollectionsResult: Result<[FeaturedCollectionDTO], Error> = .success([])
    var collectionResult: Result<CollectionDTO, Error> = .success(
        CollectionDTO(id: nil, title: nil, subtitle: nil, type: nil, tags: [], generatedAt: nil, items: [])
    )
    var articleDigestResult: Result<ContentDigestDTO, Error> = .success(
        MockDTOFactory.contentDigestDTO()
    )
    var directoryItemDigestResult: Result<ContentDigestDTO, Error> = .success(
        MockDTOFactory.contentDigestDTO()
    )
    var inheritorDigestResult: Result<ContentDigestDTO, Error> = .success(
        MockDTOFactory.contentDigestDTO()
    )
    var blendedRecommendationsResult: Result<BlendedRecommendationResponseDTO, Error> = .success(
        MockDTOFactory.blendedRecommendationResponseDTO()
    )
    var regionStoryResult: Result<DataStoryDTO, Error> = .success(
        MockDTOFactory.dataStoryDTO()
    )
    var categoryStoryResult: Result<DataStoryDTO, Error> = .success(
        MockDTOFactory.dataStoryDTO()
    )
    var yearStoryResult: Result<DataStoryDTO, Error> = .success(
        MockDTOFactory.dataStoryDTO()
    )
    var taxonomyCategoriesResult: Result<TaxonomyIndexDTO<TaxonomyTopicDTO>, Error> = .success(
        MockDTOFactory.taxonomyIndexDTO()
    )
    var taxonomyRegionsResult: Result<TaxonomyIndexDTO<TaxonomyTopicDTO>, Error> = .success(
        MockDTOFactory.taxonomyIndexDTO()
    )
    var taxonomyKindsResult: Result<TaxonomyIndexDTO<TaxonomyKindDTO>, Error> = .success(
        MockDTOFactory.taxonomyKindIndexDTO()
    )
    var taxonomyCategoryDetailResult: Result<TaxonomyCategoryDetailDTO, Error> = .success(
        MockDTOFactory.taxonomyCategoryDetailDTO()
    )
    var taxonomyRegionDetailResult: Result<TaxonomyRegionDetailDTO, Error> = .success(
        MockDTOFactory.taxonomyRegionDetailDTO()
    )
    var compareResultDTO: Result<CompareResultDTO, Error> = .success(
        MockDTOFactory.compareResultDTO()
    )

    // MARK: - 调用记录

    var homeBannersCallCount = 0
    var homeFeedCallCount = 0
    var articlesCallCount = 0
    var articleCallCount = 0
    var articleBySourceIdCallCount = 0
    var articleBySourceUrlCallCount = 0
    var articleLookupCallCount = 0
    var directoryItemsCallCount = 0
    var directoryItemCallCount = 0
    var directoryItemBySourceIdCallCount = 0
    var directoryItemLookupCallCount = 0
    var inheritorsCallCount = 0
    var inheritorCallCount = 0
    var inheritorBySourceIdCallCount = 0
    var inheritorLookupCallCount = 0
    var searchV2CallCount = 0
    var timelineV2CallCount = 0
    var directoryStatisticsOverviewCallCount = 0
    var directoryStatisticsBreakdownCallCount = 0

    // MARK: - Step 18-25 调用记录

    var discoveryTodayCallCount = 0
    var discoveryRandomCallCount = 0
    var discoveryTrendingCallCount = 0
    var discoveryWeeklyCallCount = 0
    var discoverySerendipityCallCount = 0
    var discoveryDeepDiveCallCount = 0
    var exploreIndexCallCount = 0
    var exploreTopicsCallCount = 0
    var exploreTopicCallCount = 0
    var learningPathsCallCount = 0
    var learningPathDetailCallCount = 0
    var regionAtlasCallCount = 0
    var regionAtlasDetailCallCount = 0
    var featuredCollectionsCallCount = 0
    var collectionCallCount = 0
    var topicCollectionCallCount = 0
    var articleDigestCallCount = 0
    var directoryItemDigestCallCount = 0
    var inheritorDigestCallCount = 0
    var blendedRecommendationsCallCount = 0
    var regionStoryCallCount = 0
    var categoryStoryCallCount = 0
    var yearStoryCallCount = 0
    var taxonomyCategoriesCallCount = 0
    var taxonomyRegionsCallCount = 0
    var taxonomyKindsCallCount = 0
    var taxonomyCategoryDetailCallCount = 0
    var taxonomyRegionDetailCallCount = 0
    var compareRegionsCallCount = 0
    var compareCategoriesCallCount = 0
    var compareKindsCallCount = 0

    // MARK: - 参数记录

    var lastDirectoryStatisticsOverviewKind: DirectoryItemKind?
    var lastDirectoryStatisticsBreakdownKind: DirectoryItemKind?
    var lastDirectoryStatisticsBreakdownDimension: DirectoryStatisticDimension?
    var lastDirectoryStatisticsBreakdownLimit: Int?

    // MARK: - Lookup 参数记录

    var lastArticleLookup: ArticleDetailLookup?
    var lastDirectoryLookup: DirectoryDetailLookup?
    var lastInheritorLookup: InheritorDetailLookup?

    // MARK: - 列表查询参数记录

    var lastArticleQuery: ArticleQuery?
    var lastDirectoryItemQuery: DirectoryItemQuery?
    var lastInheritorQuery: InheritorQuery?

    // MARK: - Step 18-25 参数记录

    var lastDiscoveryRandomType: SearchResultType?
    var lastDiscoveryTrendingLimit: Int?
    var lastDiscoverySerendipityQuery: DiscoverySerendipityQuery?
    var lastDiscoveryDeepDiveQuery: DiscoveryDeepDiveQuery?
    var lastExploreTopicsType: String?
    var lastExploreTopicsLimit: Int?
    var lastExploreTopicType: String?
    var lastExploreTopicKey: String?
    var lastExploreTopicLimit: Int?
    var lastLearningPathDetailId: String?
    var lastLearningPathDetailLimit: Int?
    var lastRegionAtlasDetailRegion: String?
    var lastRegionAtlasDetailLimit: Int?
    var lastCollectionId: String?
    var lastTopicCollectionType: String?
    var lastTopicCollectionKey: String?
    var lastArticleDigestId: String?
    var lastDirectoryItemDigestId: String?
    var lastInheritorDigestId: String?
    var lastBlendedRecommendationsQuery: BlendedRecommendationQuery?
    var lastRegionStoryRegion: String?
    var lastCategoryStoryCategory: String?
    var lastYearStoryYear: Int?
    var lastTaxonomyCategoriesLimit: Int?
    var lastTaxonomyRegionsLimit: Int?
    var lastTaxonomyRegionsSort: TaxonomyRegionSort?
    var lastTaxonomyCategoryDetailCategory: String?
    var lastTaxonomyCategoryDetailLimit: Int?
    var lastTaxonomyRegionDetailRegion: String?
    var lastTaxonomyRegionDetailLimit: Int?
    var lastCompareRegionsLeft: String?
    var lastCompareRegionsRight: String?
    var lastCompareRegionsLimit: Int?
    var lastCompareCategoriesLeft: String?
    var lastCompareCategoriesRight: String?
    var lastCompareCategoriesLimit: Int?
    var lastCompareKindsLeft: DirectoryItemKind?
    var lastCompareKindsRight: DirectoryItemKind?
    var lastCompareKindsLimit: Int?

    // MARK: - Repository 实现 - 首页

    func homeBanners() async throws -> [HomeBannerDTO] {
        homeBannersCallCount += 1
        return try homeBannersResult.get()
    }

    func homeFeed() async throws -> HomeFeedDTO {
        homeFeedCallCount += 1
        return try homeFeedResult.get()
    }

    // MARK: - Repository 实现 - 文章

    func articles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO> {
        articlesCallCount += 1
        lastArticleQuery = query
        return try articlesResult.get()
    }

    func article(id: String) async throws -> ArticleDetailDTO {
        articleCallCount += 1
        return try articleResult.get()
    }

    func articleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        articleBySourceIdCallCount += 1
        return try articleResult.get()
    }

    func articleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        articleBySourceUrlCallCount += 1
        return try articleResult.get()
    }

    func article(lookup: ArticleDetailLookup) async throws -> ArticleDetailDTO {
        articleLookupCallCount += 1
        lastArticleLookup = lookup
        if let articleId = lookup.articleId, !articleId.isEmpty {
            return try await article(id: articleId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return try await articleBySourceId(sourceId: sourceId, category: lookup.category)
        } else if let sourceUrl = lookup.sourceUrl, !sourceUrl.isEmpty {
            return try await articleBySourceUrl(sourceUrl: sourceUrl, category: lookup.category)
        } else {
            throw NetworkError.badRequest
        }
    }

    func articleContext(id: String) async throws -> DetailContextDTO {
        try articleContextResult.get()
    }

    // MARK: - Repository 实现 - 名录

    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO> {
        directoryItemsCallCount += 1
        lastDirectoryItemQuery = query
        return try directoryItemsResult.get()
    }

    func directoryItem(id: String) async throws -> DirectoryItemDetailDTO {
        directoryItemCallCount += 1
        return try directoryItemResult.get()
    }

    func directoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO {
        directoryItemBySourceIdCallCount += 1
        return try directoryItemResult.get()
    }

    func directoryItem(lookup: DirectoryDetailLookup) async throws -> DirectoryItemDetailDTO {
        directoryItemLookupCallCount += 1
        lastDirectoryLookup = lookup
        if let itemId = lookup.itemId, !itemId.isEmpty {
            return try await directoryItem(id: itemId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return try await directoryItemBySourceId(sourceId: sourceId, kind: lookup.kind)
        } else {
            throw NetworkError.badRequest
        }
    }

    func directoryItemContext(id: String) async throws -> DetailContextDTO {
        try directoryItemContextResult.get()
    }

    func directoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDTO {
        directoryStatisticsOverviewCallCount += 1
        lastDirectoryStatisticsOverviewKind = kind
        return try directoryStatisticsOverviewResult.get()
    }

    func directoryStatisticsBreakdown(
        kind: DirectoryItemKind,
        dimension: DirectoryStatisticDimension,
        limit: Int
    ) async throws -> DirectoryStatisticDimensionDTO {
        directoryStatisticsBreakdownCallCount += 1
        lastDirectoryStatisticsBreakdownKind = kind
        lastDirectoryStatisticsBreakdownDimension = dimension
        lastDirectoryStatisticsBreakdownLimit = limit
        return try directoryStatisticsBreakdownResult.get()
    }

    // MARK: - Repository 实现 - 传承人

    func inheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO> {
        inheritorsCallCount += 1
        lastInheritorQuery = query
        return try inheritorsResult.get()
    }

    func inheritor(id: String) async throws -> InheritorDetailDTO {
        inheritorCallCount += 1
        return try inheritorResult.get()
    }

    func inheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO {
        inheritorBySourceIdCallCount += 1
        return try inheritorResult.get()
    }

    func inheritor(lookup: InheritorDetailLookup) async throws -> InheritorDetailDTO {
        inheritorLookupCallCount += 1
        lastInheritorLookup = lookup
        if let inheritorId = lookup.inheritorId, !inheritorId.isEmpty {
            return try await inheritor(id: inheritorId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return try await inheritorBySourceId(sourceId: sourceId)
        } else {
            throw NetworkError.badRequest
        }
    }

    func inheritorContext(id: String) async throws -> DetailContextDTO {
        try inheritorContextResult.get()
    }

    // MARK: - 详情缓存读取（Mock 直接返回 nil）

    func cachedArticleDetail(lookup: ArticleDetailLookup) async -> ArticleDetailDTO? {
        nil
    }

    func cachedDirectoryDetail(lookup: DirectoryDetailLookup) async -> DirectoryItemDetailDTO? {
        nil
    }

    func cachedInheritorDetail(lookup: InheritorDetailLookup) async -> InheritorDetailDTO? {
        nil
    }

    // MARK: - Repository 实现 - 搜索

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        searchV2CallCount += 1
        return try searchV2Result.get()
    }

    func searchSuggestions(prefix: String, limit: Int) async throws -> [SearchSuggestionDTO] {
        try searchSuggestionsResult.get()
    }

    // MARK: - Repository 实现 - 时间线

    func timelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        timelineV2CallCount += 1
        return try timelineV2Result.get()
    }

    func timelineYears() async throws -> [TimelineYearBucketDTO] {
        try timelineYearsResult.get()
    }

    // MARK: - Repository 实现 - 发现

    func discoveryToday() async throws -> DiscoveryTodayDTO {
        discoveryTodayCallCount += 1
        return try discoveryTodayResult.get()
    }

    func discoveryRandom(type: SearchResultType) async throws -> DiscoveryItemDTO {
        discoveryRandomCallCount += 1
        lastDiscoveryRandomType = type
        return try discoveryRandomResult.get()
    }

    func discoveryTrending(limit: Int) async throws -> DiscoveryTrendingDTO {
        discoveryTrendingCallCount += 1
        lastDiscoveryTrendingLimit = limit
        return try discoveryTrendingResult.get()
    }

    func discoveryWeekly() async throws -> DiscoveryWeeklyDTO {
        discoveryWeeklyCallCount += 1
        return try discoveryWeeklyResult.get()
    }

    func discoverySerendipity(query: DiscoverySerendipityQuery) async throws -> DiscoveryItemDTO {
        discoverySerendipityCallCount += 1
        lastDiscoverySerendipityQuery = query
        return try discoverySerendipityResult.get()
    }

    func discoveryDeepDive(query: DiscoveryDeepDiveQuery) async throws -> DiscoveryDeepDiveDTO {
        discoveryDeepDiveCallCount += 1
        lastDiscoveryDeepDiveQuery = query
        return try discoveryDeepDiveResult.get()
    }

    // MARK: - Repository 实现 - 探索

    func exploreIndex() async throws -> ExploreIndexDTO {
        exploreIndexCallCount += 1
        return try exploreIndexResult.get()
    }

    func exploreTopics(type: String?, limit: Int) async throws -> [ExploreTopicInfoDTO] {
        exploreTopicsCallCount += 1
        lastExploreTopicsType = type
        lastExploreTopicsLimit = limit
        return try exploreTopicsResult.get()
    }

    func exploreTopic(type: String, key: String, limit: Int) async throws -> ExploreTopicV2DTO {
        exploreTopicCallCount += 1
        lastExploreTopicType = type
        lastExploreTopicKey = key
        lastExploreTopicLimit = limit
        return try exploreTopicResult.get()
    }

    func learningPaths() async throws -> [LearningPathDTO] {
        learningPathsCallCount += 1
        return try learningPathsResult.get()
    }

    func learningPathDetail(id: String, limit: Int) async throws -> LearningPathDetailDTO {
        learningPathDetailCallCount += 1
        lastLearningPathDetailId = id
        lastLearningPathDetailLimit = limit
        return try learningPathDetailResult.get()
    }

    // MARK: - Repository 实现 - 地区图谱

    func regionAtlas() async throws -> RegionAtlasDTO {
        regionAtlasCallCount += 1
        return try regionAtlasResult.get()
    }

    func regionAtlasDetail(region: String, limit: Int) async throws -> RegionAtlasDetailDTO {
        regionAtlasDetailCallCount += 1
        lastRegionAtlasDetailRegion = region
        lastRegionAtlasDetailLimit = limit
        return try regionAtlasDetailResult.get()
    }

    // MARK: - Repository 实现 - 合集

    func featuredCollections() async throws -> [FeaturedCollectionDTO] {
        featuredCollectionsCallCount += 1
        return try featuredCollectionsResult.get()
    }

    func collection(id: String) async throws -> CollectionDTO {
        collectionCallCount += 1
        lastCollectionId = id
        return try collectionResult.get()
    }

    func topicCollection(type: String, key: String) async throws -> CollectionDTO {
        topicCollectionCallCount += 1
        lastTopicCollectionType = type
        lastTopicCollectionKey = key
        return try collectionResult.get()
    }

    // MARK: - Repository 实现 - Digest

    func articleDigest(id: String) async throws -> ContentDigestDTO {
        articleDigestCallCount += 1
        lastArticleDigestId = id
        return try articleDigestResult.get()
    }

    func directoryItemDigest(id: String) async throws -> ContentDigestDTO {
        directoryItemDigestCallCount += 1
        lastDirectoryItemDigestId = id
        return try directoryItemDigestResult.get()
    }

    func inheritorDigest(id: String) async throws -> ContentDigestDTO {
        inheritorDigestCallCount += 1
        lastInheritorDigestId = id
        return try inheritorDigestResult.get()
    }

    // MARK: - Repository 实现 - 综合推荐

    func blendedRecommendations(query: BlendedRecommendationQuery) async throws -> BlendedRecommendationResponseDTO {
        blendedRecommendationsCallCount += 1
        lastBlendedRecommendationsQuery = query
        return try blendedRecommendationsResult.get()
    }

    // MARK: - Repository 实现 - 数据故事

    func regionStory(region: String) async throws -> DataStoryDTO {
        regionStoryCallCount += 1
        lastRegionStoryRegion = region
        return try regionStoryResult.get()
    }

    func categoryStory(category: String) async throws -> DataStoryDTO {
        categoryStoryCallCount += 1
        lastCategoryStoryCategory = category
        return try categoryStoryResult.get()
    }

    func yearStory(year: Int) async throws -> DataStoryDTO {
        yearStoryCallCount += 1
        lastYearStoryYear = year
        return try yearStoryResult.get()
    }

    // MARK: - Repository 实现 - 主题库

    func taxonomyCategories(limit: Int) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        taxonomyCategoriesCallCount += 1
        lastTaxonomyCategoriesLimit = limit
        return try taxonomyCategoriesResult.get()
    }

    func taxonomyRegions(limit: Int, sort: TaxonomyRegionSort) async throws -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        taxonomyRegionsCallCount += 1
        lastTaxonomyRegionsLimit = limit
        lastTaxonomyRegionsSort = sort
        return try taxonomyRegionsResult.get()
    }

    func taxonomyKinds() async throws -> TaxonomyIndexDTO<TaxonomyKindDTO> {
        taxonomyKindsCallCount += 1
        return try taxonomyKindsResult.get()
    }

    func taxonomyCategoryDetail(category: String, limit: Int) async throws -> TaxonomyCategoryDetailDTO {
        taxonomyCategoryDetailCallCount += 1
        lastTaxonomyCategoryDetailCategory = category
        lastTaxonomyCategoryDetailLimit = limit
        return try taxonomyCategoryDetailResult.get()
    }

    func taxonomyRegionDetail(region: String, limit: Int) async throws -> TaxonomyRegionDetailDTO {
        taxonomyRegionDetailCallCount += 1
        lastTaxonomyRegionDetailRegion = region
        lastTaxonomyRegionDetailLimit = limit
        return try taxonomyRegionDetailResult.get()
    }

    // MARK: - Repository 实现 - 对比

    func compareRegions(left: String, right: String, limit: Int) async throws -> CompareResultDTO {
        compareRegionsCallCount += 1
        lastCompareRegionsLeft = left
        lastCompareRegionsRight = right
        lastCompareRegionsLimit = limit
        return try compareResultDTO.get()
    }

    func compareCategories(left: String, right: String, limit: Int) async throws -> CompareResultDTO {
        compareCategoriesCallCount += 1
        lastCompareCategoriesLeft = left
        lastCompareCategoriesRight = right
        lastCompareCategoriesLimit = limit
        return try compareResultDTO.get()
    }

    func compareKinds(left: DirectoryItemKind, right: DirectoryItemKind, limit: Int) async throws -> CompareResultDTO {
        compareKindsCallCount += 1
        lastCompareKindsLeft = left
        lastCompareKindsRight = right
        lastCompareKindsLimit = limit
        return try compareResultDTO.get()
    }
}

// MARK: - Mock DTO 工厂

/// 用于创建没有默认 init 的 DTO mock 实例
private enum MockDTOFactory {
    static func contentDigestDTO() -> ContentDigestDTO {
        let json = """
        {"type":"article","id":"test","title":"Test Digest","quickRead":"Quick","highlights":[],"keyFacts":[],"keywords":[],"readingTimeMinutes":1}
        """
        return try! JSONDecoder().decode(ContentDigestDTO.self, from: json.data(using: .utf8)!)
    }

    static func blendedRecommendationResponseDTO() -> BlendedRecommendationResponseDTO {
        let json = """
        {"items":[],"generatedAt":"2026-01-01"}
        """
        return try! JSONDecoder().decode(BlendedRecommendationResponseDTO.self, from: json.data(using: .utf8)!)
    }

    static func dataStoryDTO() -> DataStoryDTO {
        let json = """
        {"id":"test","title":"Test Story","sections":[],"relatedTopics":[]}
        """
        return try! JSONDecoder().decode(DataStoryDTO.self, from: json.data(using: .utf8)!)
    }

    static func taxonomyIndexDTO() -> TaxonomyIndexDTO<TaxonomyTopicDTO> {
        let json = """
        {"items":[]}
        """
        return try! JSONDecoder().decode(TaxonomyIndexDTO<TaxonomyTopicDTO>.self, from: json.data(using: .utf8)!)
    }

    static func taxonomyKindIndexDTO() -> TaxonomyIndexDTO<TaxonomyKindDTO> {
        let json = """
        {"items":[]}
        """
        return try! JSONDecoder().decode(TaxonomyIndexDTO<TaxonomyKindDTO>.self, from: json.data(using: .utf8)!)
    }

    static func taxonomyCategoryDetailDTO() -> TaxonomyCategoryDetailDTO {
        let json = """
        {"topRegions":[],"articles":[],"directoryItems":[],"inheritors":[],"relatedCategories":[],"recommendedCollections":[]}
        """
        return try! JSONDecoder().decode(TaxonomyCategoryDetailDTO.self, from: json.data(using: .utf8)!)
    }

    static func taxonomyRegionDetailDTO() -> TaxonomyRegionDetailDTO {
        let json = """
        {"topCategories":[],"articles":[],"directoryItems":[],"inheritors":[],"relatedRegions":[],"recommendedCollections":[]}
        """
        return try! JSONDecoder().decode(TaxonomyRegionDetailDTO.self, from: json.data(using: .utf8)!)
    }

    static func regionAtlasDetailDTO() -> RegionAtlasDetailDTO {
        let json = """
        {"categoryBreakdown":[],"kindBreakdown":[],"featuredDirectoryItems":[],"featuredInheritors":[],"relatedArticles":[],"timeline":[],"relatedRegions":[]}
        """
        return try! JSONDecoder().decode(RegionAtlasDetailDTO.self, from: json.data(using: .utf8)!)
    }

    static func compareResultDTO() -> CompareResultDTO {
        let json = """
        {"left":{"directoryItemCount":0,"inheritorCount":0,"articleCount":0,"total":0,"topCategories":[],"topRegions":[]},"right":{"directoryItemCount":0,"inheritorCount":0,"articleCount":0,"total":0,"topCategories":[],"topRegions":[]},"summary":{},"sharedCategories":[],"leftUniqueCategories":[],"rightUniqueCategories":[],"sharedRegions":[],"leftUniqueRegions":[],"rightUniqueRegions":[],"leftFeaturedItems":[],"rightFeaturedItems":[]}
        """
        return try! JSONDecoder().decode(CompareResultDTO.self, from: json.data(using: .utf8)!)
    }
}
