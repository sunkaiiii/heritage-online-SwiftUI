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
struct DetailContextDTO: Decodable, Sendable {
    let related: [RelatedItemDTO]
    let recommendations: [RelatedItemDTO]
    let semanticRecommendations: [RelatedItemDTO]
    let collections: [CollectionRefDTO]
    let exploreTopics: [ExploreTopicRefDTO]

    enum CodingKeys: String, CodingKey {
        case related, recommendations, semanticRecommendations, collections, exploreTopics
    }

    init(related: [RelatedItemDTO], recommendations: [RelatedItemDTO], semanticRecommendations: [RelatedItemDTO], collections: [CollectionRefDTO], exploreTopics: [ExploreTopicRefDTO]) {
        self.related = related
        self.recommendations = recommendations
        self.semanticRecommendations = semanticRecommendations
        self.collections = collections
        self.exploreTopics = exploreTopics
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        related = try container.decodeIfPresent([RelatedItemDTO].self, forKey: .related) ?? []
        recommendations = try container.decodeIfPresent([RelatedItemDTO].self, forKey: .recommendations) ?? []
        semanticRecommendations = try container.decodeIfPresent([RelatedItemDTO].self, forKey: .semanticRecommendations) ?? []
        collections = try container.decodeIfPresent([CollectionRefDTO].self, forKey: .collections) ?? []
        exploreTopics = try container.decodeIfPresent([ExploreTopicRefDTO].self, forKey: .exploreTopics) ?? []
    }
}

/// 相关内容 DTO
struct RelatedItemDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let type: String?
    let imageUrl: String?
    let sourceId: String?
    let sourceUrl: String?
}

/// 合集引用 DTO
struct CollectionRefDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let type: String?
}

/// 探索主题引用 DTO
struct ExploreTopicRefDTO: Decodable, Sendable {
    let type: String?
    let key: String?
    let title: String?
}

/// 搜索 v2 响应 DTO
struct SearchV2ResponseDTO: Decodable, Sendable {
    let items: [SearchResultItemDTO]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case items, totalCount, page, pageSize, hasMore
    }

    init(items: [SearchResultItemDTO], totalCount: Int, page: Int, pageSize: Int, hasMore: Bool) {
        self.items = items
        self.totalCount = totalCount
        self.page = page
        self.pageSize = pageSize
        self.hasMore = hasMore
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([SearchResultItemDTO].self, forKey: .items) ?? []
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
    }
}

/// 搜索结果项 DTO
struct SearchResultItemDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let summary: String?
    let type: String?
    let imageUrl: String?
    let category: String?
    let region: String?
    let sourceId: String?
    let sourceUrl: String?
}

/// 搜索建议 DTO
struct SearchSuggestionDTO: Decodable, Sendable {
    let text: String?
    let type: String?
}

/// 时间线 v2 响应 DTO
struct TimelineV2ResponseDTO: Decodable, Sendable {
    let items: [TimelineItemDTO]
    let page: Int
    let pageSize: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case items, page, pageSize, hasMore
    }

    init(items: [TimelineItemDTO], page: Int, pageSize: Int, hasMore: Bool) {
        self.items = items
        self.page = page
        self.pageSize = pageSize
        self.hasMore = hasMore
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([TimelineItemDTO].self, forKey: .items) ?? []
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
    }
}

/// 时间线项 DTO
struct TimelineItemDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let type: String?
    let imageUrl: String?
    let publishedAt: String?
    let year: Int?
}

/// 时间线年份聚合 DTO
struct TimelineYearBucketDTO: Decodable, Sendable {
    let year: Int
    let totalCount: Int
    let articleCount: Int?
    let directoryItemCount: Int?
    let inheritorCount: Int?
}
