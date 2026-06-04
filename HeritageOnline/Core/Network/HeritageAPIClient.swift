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

// MARK: - DTO 占位符

/// 分页结果 DTO
/// 对齐 Android PagedResult
struct PagedResultDTO<T: Decodable & Sendable>: Decodable, Sendable {
    let items: [T]
    let page: Int
    let pageSize: Int
    let total: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case items, page, pageSize, total, hasMore
    }

    init(items: [T], page: Int, pageSize: Int, total: Int, hasMore: Bool) {
        self.items = items
        self.page = page
        self.pageSize = pageSize
        self.total = total
        self.hasMore = hasMore
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([T].self, forKey: .items) ?? []
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
    }
}

/// 首页 Banner DTO
/// 对齐 Android HomeBannerDto
struct HomeBannerDTO: Decodable, Sendable {
    let id: String?
    let sortOrder: Int?
    let targetUrl: String?
    let displayImage: MediaAssetDTO?
    let mobileImage: MediaAssetDTO?
    let desktopImage: MediaAssetDTO?
}

/// 首页 Feed DTO
/// 对齐 Android HomeFeedDto
struct HomeFeedDTO: Decodable, Sendable {
    let banners: [HomeBannerDTO]
    let latestNews: [ArticleSummaryDTO]
    let latestSpecialTopics: [ArticleSummaryDTO]
    let latestForumArticles: [ArticleSummaryDTO]
    let featuredDirectoryItems: [DirectoryItemSummaryDTO]
    let featuredInheritors: [InheritorSummaryDTO]
    let summary: HomeFeedSummaryDTO?

    enum CodingKeys: String, CodingKey {
        case banners, latestNews, latestSpecialTopics, latestForumArticles
        case featuredDirectoryItems, featuredInheritors, summary
    }

    init(banners: [HomeBannerDTO], latestNews: [ArticleSummaryDTO], latestSpecialTopics: [ArticleSummaryDTO], latestForumArticles: [ArticleSummaryDTO], featuredDirectoryItems: [DirectoryItemSummaryDTO], featuredInheritors: [InheritorSummaryDTO], summary: HomeFeedSummaryDTO?) {
        self.banners = banners
        self.latestNews = latestNews
        self.latestSpecialTopics = latestSpecialTopics
        self.latestForumArticles = latestForumArticles
        self.featuredDirectoryItems = featuredDirectoryItems
        self.featuredInheritors = featuredInheritors
        self.summary = summary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        banners = try container.decodeIfPresent([HomeBannerDTO].self, forKey: .banners) ?? []
        latestNews = try container.decodeIfPresent([ArticleSummaryDTO].self, forKey: .latestNews) ?? []
        latestSpecialTopics = try container.decodeIfPresent([ArticleSummaryDTO].self, forKey: .latestSpecialTopics) ?? []
        latestForumArticles = try container.decodeIfPresent([ArticleSummaryDTO].self, forKey: .latestForumArticles) ?? []
        featuredDirectoryItems = try container.decodeIfPresent([DirectoryItemSummaryDTO].self, forKey: .featuredDirectoryItems) ?? []
        featuredInheritors = try container.decodeIfPresent([InheritorSummaryDTO].self, forKey: .featuredInheritors) ?? []
        summary = try container.decodeIfPresent(HomeFeedSummaryDTO.self, forKey: .summary)
    }
}

/// 文章摘要 DTO
/// 对齐 Android ArticleSummaryDto
struct ArticleSummaryDTO: Decodable, Sendable {
    let id: String?
    let category: String?
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
}

/// 文章详情 DTO
/// 对齐 Android ArticleDetailDto
struct ArticleDetailDTO: Decodable, Sendable {
    let id: String?
    let category: String?
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
    let sourceName: String?
    let author: String?
    let editor: String?
    let contentBlocks: [ArticleContentBlockDTO]
    let relatedArticles: [ArticleReferenceDTO]

    enum CodingKeys: String, CodingKey {
        case id, category, title, summary, publishedAt, coverImage, sourceUrl
        case sourceName, author, editor, contentBlocks, relatedArticles
    }

    init(id: String?, category: String?, title: String?, summary: String?, publishedAt: String?, coverImage: MediaAssetDTO?, sourceUrl: String?, sourceName: String?, author: String?, editor: String?, contentBlocks: [ArticleContentBlockDTO], relatedArticles: [ArticleReferenceDTO]) {
        self.id = id
        self.category = category
        self.title = title
        self.summary = summary
        self.publishedAt = publishedAt
        self.coverImage = coverImage
        self.sourceUrl = sourceUrl
        self.sourceName = sourceName
        self.author = author
        self.editor = editor
        self.contentBlocks = contentBlocks
        self.relatedArticles = relatedArticles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        sourceName = try container.decodeIfPresent(String.self, forKey: .sourceName)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        editor = try container.decodeIfPresent(String.self, forKey: .editor)
        contentBlocks = try container.decodeIfPresent([ArticleContentBlockDTO].self, forKey: .contentBlocks) ?? []
        relatedArticles = try container.decodeIfPresent([ArticleReferenceDTO].self, forKey: .relatedArticles) ?? []
    }
}

/// 名录摘要 DTO
/// 对齐 Android DirectoryItemSummaryDto
struct DirectoryItemSummaryDTO: Decodable, Sendable {
    let id: String?
    let kind: String?
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let projectCode: String?
    let batch: String?
    let publishedYear: Int?
    let listType: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
}

/// 名录详情 DTO
/// 对齐 Android DirectoryItemDetailDto
struct DirectoryItemDetailDTO: Decodable, Sendable {
    let id: String?
    let kind: String?
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let projectCode: String?
    let batch: String?
    let publishedYear: Int?
    let listType: String?
    let nominationType: String?
    let protectionUnit: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
    let gallery: [MediaAssetDTO]
    let contentBlocks: [ArticleContentBlockDTO]
    let relatedProjects: [DirectoryReferenceDTO]
    let relatedInheritors: [DirectoryReferenceDTO]
    let relatedDocuments: [DirectoryReferenceDTO]

    enum CodingKeys: String, CodingKey {
        case id, kind, title, summary, category, region, projectCode, batch, publishedYear
        case listType, nominationType, protectionUnit, coverImage, sourceUrl
        case gallery, contentBlocks, relatedProjects, relatedInheritors, relatedDocuments
    }

    init(id: String?, kind: String?, title: String?, summary: String?, category: String?, region: String?, projectCode: String?, batch: String?, publishedYear: Int?, listType: String?, nominationType: String?, protectionUnit: String?, coverImage: MediaAssetDTO?, sourceUrl: String?, gallery: [MediaAssetDTO], contentBlocks: [ArticleContentBlockDTO], relatedProjects: [DirectoryReferenceDTO], relatedInheritors: [DirectoryReferenceDTO], relatedDocuments: [DirectoryReferenceDTO]) {
        self.id = id
        self.kind = kind
        self.title = title
        self.summary = summary
        self.category = category
        self.region = region
        self.projectCode = projectCode
        self.batch = batch
        self.publishedYear = publishedYear
        self.listType = listType
        self.nominationType = nominationType
        self.protectionUnit = protectionUnit
        self.coverImage = coverImage
        self.sourceUrl = sourceUrl
        self.gallery = gallery
        self.contentBlocks = contentBlocks
        self.relatedProjects = relatedProjects
        self.relatedInheritors = relatedInheritors
        self.relatedDocuments = relatedDocuments
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        projectCode = try container.decodeIfPresent(String.self, forKey: .projectCode)
        batch = try container.decodeIfPresent(String.self, forKey: .batch)
        publishedYear = try container.decodeIfPresent(Int.self, forKey: .publishedYear)
        listType = try container.decodeIfPresent(String.self, forKey: .listType)
        nominationType = try container.decodeIfPresent(String.self, forKey: .nominationType)
        protectionUnit = try container.decodeIfPresent(String.self, forKey: .protectionUnit)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        gallery = try container.decodeIfPresent([MediaAssetDTO].self, forKey: .gallery) ?? []
        contentBlocks = try container.decodeIfPresent([ArticleContentBlockDTO].self, forKey: .contentBlocks) ?? []
        relatedProjects = try container.decodeIfPresent([DirectoryReferenceDTO].self, forKey: .relatedProjects) ?? []
        relatedInheritors = try container.decodeIfPresent([DirectoryReferenceDTO].self, forKey: .relatedInheritors) ?? []
        relatedDocuments = try container.decodeIfPresent([DirectoryReferenceDTO].self, forKey: .relatedDocuments) ?? []
    }
}

/// 传承人摘要 DTO
/// 对齐 Android InheritorSummaryDto
struct InheritorSummaryDTO: Decodable, Sendable {
    let id: String?
    let name: String?
    let gender: String?
    let birthDateText: String?
    let ethnicity: String?
    let category: String?
    let projectCode: String?
    let projectName: String?
    let region: String?
    let batch: String?
    let description: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
}

/// 传承人详情 DTO
/// 对齐 Android InheritorDetailDto
struct InheritorDetailDTO: Decodable, Sendable {
    let id: String?
    let name: String?
    let gender: String?
    let birthDateText: String?
    let ethnicity: String?
    let category: String?
    let projectCode: String?
    let projectName: String?
    let region: String?
    let batch: String?
    let description: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
    let contentBlocks: [ArticleContentBlockDTO]
    let relatedProjects: [DirectoryReferenceDTO]
    let relatedInheritors: [DirectoryReferenceDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, gender, birthDateText, ethnicity, category, projectCode, projectName
        case region, batch, description, coverImage, sourceUrl
        case contentBlocks, relatedProjects, relatedInheritors
    }

    init(id: String?, name: String?, gender: String?, birthDateText: String?, ethnicity: String?, category: String?, projectCode: String?, projectName: String?, region: String?, batch: String?, description: String?, coverImage: MediaAssetDTO?, sourceUrl: String?, contentBlocks: [ArticleContentBlockDTO], relatedProjects: [DirectoryReferenceDTO], relatedInheritors: [DirectoryReferenceDTO]) {
        self.id = id
        self.name = name
        self.gender = gender
        self.birthDateText = birthDateText
        self.ethnicity = ethnicity
        self.category = category
        self.projectCode = projectCode
        self.projectName = projectName
        self.region = region
        self.batch = batch
        self.description = description
        self.coverImage = coverImage
        self.sourceUrl = sourceUrl
        self.contentBlocks = contentBlocks
        self.relatedProjects = relatedProjects
        self.relatedInheritors = relatedInheritors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        birthDateText = try container.decodeIfPresent(String.self, forKey: .birthDateText)
        ethnicity = try container.decodeIfPresent(String.self, forKey: .ethnicity)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        projectCode = try container.decodeIfPresent(String.self, forKey: .projectCode)
        projectName = try container.decodeIfPresent(String.self, forKey: .projectName)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        batch = try container.decodeIfPresent(String.self, forKey: .batch)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        contentBlocks = try container.decodeIfPresent([ArticleContentBlockDTO].self, forKey: .contentBlocks) ?? []
        relatedProjects = try container.decodeIfPresent([DirectoryReferenceDTO].self, forKey: .relatedProjects) ?? []
        relatedInheritors = try container.decodeIfPresent([DirectoryReferenceDTO].self, forKey: .relatedInheritors) ?? []
    }
}

/// 详情 Context DTO
/// 详情 Context DTO
/// 对齐 Android DetailContextDto
struct DetailContextDTO: Decodable, Sendable {
    let related: [RelatedItemDTO]
    let recommendations: [RelatedItemDTO]
    let semanticRecommendations: [RelatedItemDTO]
    let collections: [CollectionRefDTO]
    let exploreTopics: [ExploreTopicRefDTO]
    let graph: [GraphEdgeDTO]

    enum CodingKeys: String, CodingKey {
        case related, recommendations, semanticRecommendations, collections, exploreTopics, graph
    }

    init(related: [RelatedItemDTO], recommendations: [RelatedItemDTO], semanticRecommendations: [RelatedItemDTO], collections: [CollectionRefDTO], exploreTopics: [ExploreTopicRefDTO], graph: [GraphEdgeDTO]) {
        self.related = related
        self.recommendations = recommendations
        self.semanticRecommendations = semanticRecommendations
        self.collections = collections
        self.exploreTopics = exploreTopics
        self.graph = graph
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        related = try container.decodeIfPresent([RelatedItemDTO].self, forKey: .related) ?? []
        recommendations = try container.decodeIfPresent([RelatedItemDTO].self, forKey: .recommendations) ?? []
        semanticRecommendations = try container.decodeIfPresent([RelatedItemDTO].self, forKey: .semanticRecommendations) ?? []
        collections = try container.decodeIfPresent([CollectionRefDTO].self, forKey: .collections) ?? []
        exploreTopics = try container.decodeIfPresent([ExploreTopicRefDTO].self, forKey: .exploreTopics) ?? []
        graph = try container.decodeIfPresent([GraphEdgeDTO].self, forKey: .graph) ?? []
    }
}

/// 相关内容 DTO
/// 对齐 Android RelatedItemDto
struct RelatedItemDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let type: String?
    let kind: String?
    let category: String?
    let summary: String?
    let imageUrl: String?
    let coverImage: MediaAssetDTO?
    let sourceId: String?
    let sourceUrl: String?
}

/// 合集引用 DTO
struct CollectionRefDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let type: String?
}

/// 探索主题引用 DTO
struct ExploreTopicRefDTO: Decodable, Sendable {
    let type: String?
    let key: String?
    let title: String?
}

/// 关系图谱边 DTO
struct GraphEdgeDTO: Decodable, Sendable {
    let fromId: String?
    let fromType: String?
    let fromTitle: String?
    let toId: String?
    let toType: String?
    let toTitle: String?
    let relation: String?
}

/// 搜索 v2 响应 DTO
/// 对齐 Android SearchV2ResponseDto
struct SearchV2ResponseDTO: Decodable, Sendable {
    let items: [SearchResultItemDTO]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
    let facets: SearchFacetsDTO?
    let query: String?

    enum CodingKeys: String, CodingKey {
        case items, total, totalCount, page, pageSize, hasMore, facets, query
    }

    init(items: [SearchResultItemDTO], total: Int, page: Int, pageSize: Int, hasMore: Bool, facets: SearchFacetsDTO?, query: String?) {
        self.items = items
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.hasMore = hasMore
        self.facets = facets
        self.query = query
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([SearchResultItemDTO].self, forKey: .items) ?? []
        total = try container.decodeIfPresent(Int.self, forKey: .total)
            ?? container.decodeIfPresent(Int.self, forKey: .totalCount)
            ?? 0
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        facets = try container.decodeIfPresent(SearchFacetsDTO.self, forKey: .facets)
        query = try container.decodeIfPresent(String.self, forKey: .query)
    }
}

/// 搜索分面 DTO
struct SearchFacetsDTO: Decodable, Sendable {
    let types: [FacetBucketDTO]?
    let categories: [FacetBucketDTO]?
    let regions: [FacetBucketDTO]?
    let years: [FacetBucketDTO]?
    let kinds: [FacetBucketDTO]?
}

/// 搜索结果项 DTO
/// 对齐 Android SearchResultItemDto
struct SearchResultItemDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let summary: String?
    let type: String?
    let kind: String?
    let category: String?
    let region: String?
    let publishedAt: String?
    let publishedYear: Int?
    let coverImage: MediaAssetDTO?
    let sourceId: String?
    let sourceUrl: String?
    let highlights: [String]?
    let matchedFields: [String]?
    let score: Double?
}

/// 搜索建议 DTO
struct SearchSuggestionDTO: Decodable, Sendable {
    let text: String?
    let type: String?
}

/// 时间线 v2 响应 DTO
/// 对齐 Android TimelineV2ResponseDto
struct TimelineV2ResponseDTO: Decodable, Sendable {
    let items: [TimelineItemDTO]
    let total: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
    let facets: TimelineFacetsDTO?

    enum CodingKeys: String, CodingKey {
        case items, total, totalCount, page, pageSize, hasMore, facets
    }

    init(items: [TimelineItemDTO], total: Int, page: Int, pageSize: Int, hasMore: Bool, facets: TimelineFacetsDTO?) {
        self.items = items
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.hasMore = hasMore
        self.facets = facets
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([TimelineItemDTO].self, forKey: .items) ?? []
        total = try container.decodeIfPresent(Int.self, forKey: .total)
            ?? container.decodeIfPresent(Int.self, forKey: .totalCount)
            ?? 0
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        facets = try container.decodeIfPresent(TimelineFacetsDTO.self, forKey: .facets)
    }
}

/// 时间线分面 DTO
struct TimelineFacetsDTO: Decodable, Sendable {
    let types: [FacetBucketDTO]?
    let categories: [FacetBucketDTO]?
    let regions: [FacetBucketDTO]?
}

/// 时间线项 DTO
/// 对齐 Android TimelineItemDto
struct TimelineItemDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let summary: String?
    let type: String?
    let category: String?
    let kind: String?
    let region: String?
    let date: String?
    let year: Int?
    let publishedAt: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
}

/// 时间线年份聚合 DTO
/// 对齐 Android TimelineYearBucketDto
struct TimelineYearBucketDTO: Decodable, Sendable {
    let year: Int
    let total: Int
    let articleCount: Int?
    let directoryItemCount: Int?
    let inheritorCount: Int?

    enum CodingKeys: String, CodingKey {
        case year, total, totalCount, articleCount, directoryItemCount, inheritorCount
    }

    init(year: Int, total: Int, articleCount: Int?, directoryItemCount: Int?, inheritorCount: Int?) {
        self.year = year
        self.total = total
        self.articleCount = articleCount
        self.directoryItemCount = directoryItemCount
        self.inheritorCount = inheritorCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        year = try container.decode(Int.self, forKey: .year)
        total = try container.decodeIfPresent(Int.self, forKey: .total)
            ?? container.decodeIfPresent(Int.self, forKey: .totalCount)
            ?? 0
        articleCount = try container.decodeIfPresent(Int.self, forKey: .articleCount)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount)
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount)
    }
}

// MARK: - Digest DTO

/// 内容速览 DTO
/// 对齐 Android ContentDigestDto
struct ContentDigestDTO: Decodable, Sendable {
    let type: String?
    let id: String?
    let title: String?
    let quickRead: String?
    let highlights: [String]
    let keyFacts: [DigestFactDTO]
    let keywords: [String]
    let readingTimeMinutes: Int
    let sourceUrl: String?
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case type, id, title, quickRead, highlights, keyFacts, keywords, readingTimeMinutes, sourceUrl, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        quickRead = try container.decodeIfPresent(String.self, forKey: .quickRead)
        highlights = try container.decodeIfPresent([String].self, forKey: .highlights) ?? []
        keyFacts = try container.decodeIfPresent([DigestFactDTO].self, forKey: .keyFacts) ?? []
        keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
        readingTimeMinutes = try container.decodeIfPresent(Int.self, forKey: .readingTimeMinutes) ?? 0
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// Digest 事实 DTO
/// 对齐 Android DigestFactDto
struct DigestFactDTO: Decodable, Sendable {
    let label: String
    let value: String
}

// MARK: - Blended Recommendation DTO

/// 综合推荐响应 DTO
/// 对齐 Android BlendedRecommendationResponseDto
struct BlendedRecommendationResponseDTO: Decodable, Sendable {
    let items: [BlendedRecommendationItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case items, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([BlendedRecommendationItemDTO].self, forKey: .items) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 综合推荐项 DTO
/// 对齐 Android BlendedRecommendationItemDto
struct BlendedRecommendationItemDTO: Decodable, Sendable {
    let id: String
    let type: String
    let title: String
    let subtitle: String?
    let score: Double
    let reasons: [String]
    let scoreBreakdown: RecommendationScoreBreakdownDTO
    let category: String?
    let region: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, type, title, subtitle, score, reasons, scoreBreakdown, category, region, coverImage, sourceUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        score = try container.decodeIfPresent(Double.self, forKey: .score) ?? 0.0
        reasons = try container.decodeIfPresent([String].self, forKey: .reasons) ?? []
        scoreBreakdown = try container.decodeIfPresent(RecommendationScoreBreakdownDTO.self, forKey: .scoreBreakdown) ?? RecommendationScoreBreakdownDTO()
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}

/// 推荐分数分解 DTO
/// 对齐 Android RecommendationScoreBreakdownDto
struct RecommendationScoreBreakdownDTO: Decodable, Sendable {
    let explicit: Double
    let inferred: Double
    let embedding: Double
    let sameCategory: Double
    let sameRegion: Double

    init(explicit: Double = 0.0, inferred: Double = 0.0, embedding: Double = 0.0, sameCategory: Double = 0.0, sameRegion: Double = 0.0) {
        self.explicit = explicit
        self.inferred = inferred
        self.embedding = embedding
        self.sameCategory = sameCategory
        self.sameRegion = sameRegion
    }

    enum CodingKeys: String, CodingKey {
        case explicit, inferred, embedding, sameCategory, sameRegion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        explicit = try container.decodeIfPresent(Double.self, forKey: .explicit) ?? 0.0
        inferred = try container.decodeIfPresent(Double.self, forKey: .inferred) ?? 0.0
        embedding = try container.decodeIfPresent(Double.self, forKey: .embedding) ?? 0.0
        sameCategory = try container.decodeIfPresent(Double.self, forKey: .sameCategory) ?? 0.0
        sameRegion = try container.decodeIfPresent(Double.self, forKey: .sameRegion) ?? 0.0
    }
}

// MARK: - Story DTO

/// 数据故事 DTO
/// 对齐 Android DataStoryDto
struct DataStoryDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let heroImage: MediaAssetDTO?
    let sections: [DataStorySectionDTO]
    let relatedTopics: [ExploreTopicRefDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, heroImage, sections, relatedTopics, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        heroImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .heroImage)
        sections = try container.decodeIfPresent([DataStorySectionDTO].self, forKey: .sections) ?? []
        relatedTopics = try container.decodeIfPresent([ExploreTopicRefDTO].self, forKey: .relatedTopics) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 数据故事区块 DTO
/// 对齐 Android DataStorySectionDto
struct DataStorySectionDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let type: String?
    let body: String?
    let items: [DataStoryItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, type, body, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        items = try container.decodeIfPresent([DataStoryItemDTO].self, forKey: .items) ?? []
    }
}

/// 数据故事内容项 DTO
/// 对齐 Android DataStoryItemDto
struct DataStoryItemDTO: Decodable, Sendable {
    let type: String?
    let id: String?
    let title: String?
    let summary: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?

    enum CodingKeys: String, CodingKey {
        case type, id, title, summary, coverImage, sourceUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}

// MARK: - Taxonomy DTO

/// 主题库主题 DTO
/// 对齐 Android TaxonomyTopicDto
struct TaxonomyTopicDTO: Decodable, Sendable {
    let type: String?
    let key: String?
    let title: String?
    let subtitle: String?
    let directoryItemCount: Int
    let inheritorCount: Int
    let articleCount: Int
    let total: Int
    let topRegions: [TaxonomyRegionCountDTO]
    let topCategories: [TaxonomyCategoryCountDTO]
    let coverImage: MediaAssetDTO?

    enum CodingKeys: String, CodingKey {
        case type, key, title, subtitle, directoryItemCount, inheritorCount, articleCount, total
        case topRegions, topCategories, coverImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount) ?? 0
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount) ?? 0
        articleCount = try container.decodeIfPresent(Int.self, forKey: .articleCount) ?? 0
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        topRegions = try container.decodeIfPresent([TaxonomyRegionCountDTO].self, forKey: .topRegions) ?? []
        topCategories = try container.decodeIfPresent([TaxonomyCategoryCountDTO].self, forKey: .topCategories) ?? []
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
    }
}

/// 主题库地区计数 DTO
struct TaxonomyRegionCountDTO: Decodable, Sendable {
    let region: String
    let count: Int
}

/// 主题库分类计数 DTO
struct TaxonomyCategoryCountDTO: Decodable, Sendable {
    let category: String
    let count: Int
}

/// 主题库种类 DTO
/// 对齐 Android TaxonomyKindDto
struct TaxonomyKindDTO: Decodable, Sendable {
    let key: String?
    let title: String?
    let directoryItemCount: Int
    let inheritorCount: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case key, title, directoryItemCount, inheritorCount, total
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount) ?? 0
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount) ?? 0
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
    }
}

/// 主题库索引 DTO
/// 对齐 Android TaxonomyIndexDto
struct TaxonomyIndexDTO<T: Decodable & Sendable>: Decodable, Sendable {
    let items: [T]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case items, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([T].self, forKey: .items) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 主题库统计 DTO
struct TaxonomyStatDTO: Decodable, Sendable {
    let directoryItemCount: Int
    let inheritorCount: Int
    let articleCount: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case directoryItemCount, inheritorCount, articleCount, total
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount) ?? 0
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount) ?? 0
        articleCount = try container.decodeIfPresent(Int.self, forKey: .articleCount) ?? 0
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
    }
}

/// 主题库分类详情 DTO
/// 对齐 Android TaxonomyCategoryDetailDto
struct TaxonomyCategoryDetailDTO: Decodable, Sendable {
    let topic: TaxonomyTopicDTO?
    let stats: TaxonomyStatDTO?
    let topRegions: [TaxonomyRegionCountDTO]
    let articles: [ArticleSummaryDTO]
    let directoryItems: [DirectoryItemSummaryDTO]
    let inheritors: [InheritorSummaryDTO]
    let relatedCategories: [String]
    let recommendedCollections: [CollectionItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case topic, stats, topRegions, articles, directoryItems, inheritors
        case relatedCategories, recommendedCollections, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        topic = try container.decodeIfPresent(TaxonomyTopicDTO.self, forKey: .topic)
        stats = try container.decodeIfPresent(TaxonomyStatDTO.self, forKey: .stats)
        topRegions = try container.decodeIfPresent([TaxonomyRegionCountDTO].self, forKey: .topRegions) ?? []
        articles = try container.decodeIfPresent([ArticleSummaryDTO].self, forKey: .articles) ?? []
        directoryItems = try container.decodeIfPresent([DirectoryItemSummaryDTO].self, forKey: .directoryItems) ?? []
        inheritors = try container.decodeIfPresent([InheritorSummaryDTO].self, forKey: .inheritors) ?? []
        relatedCategories = try container.decodeIfPresent([String].self, forKey: .relatedCategories) ?? []
        recommendedCollections = try container.decodeIfPresent([CollectionItemDTO].self, forKey: .recommendedCollections) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 主题库地区详情 DTO
/// 对齐 Android TaxonomyRegionDetailDto
struct TaxonomyRegionDetailDTO: Decodable, Sendable {
    let topic: TaxonomyTopicDTO?
    let stats: TaxonomyStatDTO?
    let topCategories: [TaxonomyCategoryCountDTO]
    let articles: [ArticleSummaryDTO]
    let directoryItems: [DirectoryItemSummaryDTO]
    let inheritors: [InheritorSummaryDTO]
    let relatedRegions: [String]
    let recommendedCollections: [CollectionItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case topic, stats, topCategories, articles, directoryItems, inheritors
        case relatedRegions, recommendedCollections, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        topic = try container.decodeIfPresent(TaxonomyTopicDTO.self, forKey: .topic)
        stats = try container.decodeIfPresent(TaxonomyStatDTO.self, forKey: .stats)
        topCategories = try container.decodeIfPresent([TaxonomyCategoryCountDTO].self, forKey: .topCategories) ?? []
        articles = try container.decodeIfPresent([ArticleSummaryDTO].self, forKey: .articles) ?? []
        directoryItems = try container.decodeIfPresent([DirectoryItemSummaryDTO].self, forKey: .directoryItems) ?? []
        inheritors = try container.decodeIfPresent([InheritorSummaryDTO].self, forKey: .inheritors) ?? []
        relatedRegions = try container.decodeIfPresent([String].self, forKey: .relatedRegions) ?? []
        recommendedCollections = try container.decodeIfPresent([CollectionItemDTO].self, forKey: .recommendedCollections) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

// MARK: - Compare DTO

/// 对比结果 DTO
/// 对齐 Android CompareResultDto
struct CompareResultDTO: Decodable, Sendable {
    let left: CompareSideDTO
    let right: CompareSideDTO
    let summary: CompareSummaryDTO
    let sharedCategories: [String]
    let leftUniqueCategories: [String]
    let rightUniqueCategories: [String]
    let sharedRegions: [String]
    let leftUniqueRegions: [String]
    let rightUniqueRegions: [String]
    let leftFeaturedItems: [CollectionItemDTO]
    let rightFeaturedItems: [CollectionItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case left, right, summary
        case sharedCategories, leftUniqueCategories, rightUniqueCategories
        case sharedRegions, leftUniqueRegions, rightUniqueRegions
        case leftFeaturedItems, rightFeaturedItems, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        left = try container.decode(CompareSideDTO.self, forKey: .left)
        right = try container.decode(CompareSideDTO.self, forKey: .right)
        summary = try container.decode(CompareSummaryDTO.self, forKey: .summary)
        sharedCategories = try container.decodeIfPresent([String].self, forKey: .sharedCategories) ?? []
        leftUniqueCategories = try container.decodeIfPresent([String].self, forKey: .leftUniqueCategories) ?? []
        rightUniqueCategories = try container.decodeIfPresent([String].self, forKey: .rightUniqueCategories) ?? []
        sharedRegions = try container.decodeIfPresent([String].self, forKey: .sharedRegions) ?? []
        leftUniqueRegions = try container.decodeIfPresent([String].self, forKey: .leftUniqueRegions) ?? []
        rightUniqueRegions = try container.decodeIfPresent([String].self, forKey: .rightUniqueRegions) ?? []
        leftFeaturedItems = try container.decodeIfPresent([CollectionItemDTO].self, forKey: .leftFeaturedItems) ?? []
        rightFeaturedItems = try container.decodeIfPresent([CollectionItemDTO].self, forKey: .rightFeaturedItems) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 对比单侧 DTO
struct CompareSideDTO: Decodable, Sendable {
    let key: String?
    let title: String?
    let directoryItemCount: Int
    let inheritorCount: Int
    let articleCount: Int
    let total: Int
    let topCategories: [TaxonomyCategoryCountDTO]
    let topRegions: [TaxonomyRegionCountDTO]

    enum CodingKeys: String, CodingKey {
        case key, title, directoryItemCount, inheritorCount, articleCount, total
        case topCategories, topRegions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount) ?? 0
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount) ?? 0
        articleCount = try container.decodeIfPresent(Int.self, forKey: .articleCount) ?? 0
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        topCategories = try container.decodeIfPresent([TaxonomyCategoryCountDTO].self, forKey: .topCategories) ?? []
        topRegions = try container.decodeIfPresent([TaxonomyRegionCountDTO].self, forKey: .topRegions) ?? []
    }
}

/// 对比摘要 DTO
struct CompareSummaryDTO: Decodable, Sendable {
    let winnerByDirectoryItems: String?
    let winnerByInheritors: String?
    let winnerByArticles: String?
    let winnerByTotal: String?
}
