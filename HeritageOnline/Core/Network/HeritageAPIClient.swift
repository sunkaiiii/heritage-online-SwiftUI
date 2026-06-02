import Foundation

/// Heritage API 客户端接口
/// 完全对齐 Android HeritageApiClient
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
struct PagedResultDTO<T: Decodable & Sendable>: Decodable, Sendable {
    let items: [T]
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let hasMore: Bool

    enum CodingKeys: String, CodingKey {
        case items, page, pageSize, totalCount, hasMore
    }

    init(items: [T], page: Int, pageSize: Int, totalCount: Int, hasMore: Bool) {
        self.items = items
        self.page = page
        self.pageSize = pageSize
        self.totalCount = totalCount
        self.hasMore = hasMore
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([T].self, forKey: .items) ?? []
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        totalCount = try container.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
    }
}

/// 首页 Banner DTO
struct HomeBannerDTO: Decodable, Sendable {
    let id: String
    let title: String?
    let subtitle: String?
    let imageUrl: String?
    let linkUrl: String?
}

/// 首页 Feed DTO
struct HomeFeedDTO: Decodable, Sendable {
    let banners: [HomeBannerDTO]
    let articles: [ArticleSummaryDTO]

    enum CodingKeys: String, CodingKey {
        case banners, articles
    }

    init(banners: [HomeBannerDTO], articles: [ArticleSummaryDTO]) {
        self.banners = banners
        self.articles = articles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        banners = try container.decodeIfPresent([HomeBannerDTO].self, forKey: .banners) ?? []
        articles = try container.decodeIfPresent([ArticleSummaryDTO].self, forKey: .articles) ?? []
    }
}

/// 文章摘要 DTO
struct ArticleSummaryDTO: Decodable, Sendable {
    let id: String
    let title: String?
    let summary: String?
    let category: String?
    let imageUrl: String?
    let publishedAt: String?
    let sourceUrl: String?
}

/// 文章详情 DTO
struct ArticleDetailDTO: Decodable, Sendable {
    let id: String
    let title: String?
    let summary: String?
    let category: String?
    let imageUrl: String?
    let publishedAt: String?
    let sourceUrl: String?
    let author: String?
    let content: String?
    let contentBlocks: [ContentBlockDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, summary, category, imageUrl, publishedAt, sourceUrl, author, content, contentBlocks
    }

    init(id: String, title: String?, summary: String?, category: String?, imageUrl: String?, publishedAt: String?, sourceUrl: String?, author: String?, content: String?, contentBlocks: [ContentBlockDTO]) {
        self.id = id
        self.title = title
        self.summary = summary
        self.category = category
        self.imageUrl = imageUrl
        self.publishedAt = publishedAt
        self.sourceUrl = sourceUrl
        self.author = author
        self.content = content
        self.contentBlocks = contentBlocks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        contentBlocks = try container.decodeIfPresent([ContentBlockDTO].self, forKey: .contentBlocks) ?? []
    }
}

/// 内容块 DTO
struct ContentBlockDTO: Decodable, Sendable {
    let type: String?
    let text: String?
    let imageUrl: String?
}

/// 名录摘要 DTO
struct DirectoryItemSummaryDTO: Decodable, Sendable {
    let id: String
    let title: String?
    let summary: String?
    let kind: String?
    let category: String?
    let region: String?
    let imageUrl: String?
    let projectCode: String?
}

/// 名录详情 DTO
struct DirectoryItemDetailDTO: Decodable, Sendable {
    let id: String
    let title: String?
    let summary: String?
    let kind: String?
    let category: String?
    let region: String?
    let imageUrl: String?
    let projectCode: String?
    let batch: String?
    let publishedYear: Int?
    let content: String?
    let contentBlocks: [ContentBlockDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, summary, kind, category, region, imageUrl, projectCode, batch, publishedYear, content, contentBlocks
    }

    init(id: String, title: String?, summary: String?, kind: String?, category: String?, region: String?, imageUrl: String?, projectCode: String?, batch: String?, publishedYear: Int?, content: String?, contentBlocks: [ContentBlockDTO]) {
        self.id = id
        self.title = title
        self.summary = summary
        self.kind = kind
        self.category = category
        self.region = region
        self.imageUrl = imageUrl
        self.projectCode = projectCode
        self.batch = batch
        self.publishedYear = publishedYear
        self.content = content
        self.contentBlocks = contentBlocks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        projectCode = try container.decodeIfPresent(String.self, forKey: .projectCode)
        batch = try container.decodeIfPresent(String.self, forKey: .batch)
        publishedYear = try container.decodeIfPresent(Int.self, forKey: .publishedYear)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        contentBlocks = try container.decodeIfPresent([ContentBlockDTO].self, forKey: .contentBlocks) ?? []
    }
}

/// 传承人摘要 DTO
struct InheritorSummaryDTO: Decodable, Sendable {
    let id: String
    let name: String?
    let projectName: String?
    let gender: String?
    let ethnicity: String?
    let category: String?
    let region: String?
    let imageUrl: String?
}

/// 传承人详情 DTO
struct InheritorDetailDTO: Decodable, Sendable {
    let id: String
    let name: String?
    let projectName: String?
    let gender: String?
    let ethnicity: String?
    let category: String?
    let region: String?
    let imageUrl: String?
    let description: String?
    let contentBlocks: [ContentBlockDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, projectName, gender, ethnicity, category, region, imageUrl, description, contentBlocks
    }

    init(id: String, name: String?, projectName: String?, gender: String?, ethnicity: String?, category: String?, region: String?, imageUrl: String?, description: String?, contentBlocks: [ContentBlockDTO]) {
        self.id = id
        self.name = name
        self.projectName = projectName
        self.gender = gender
        self.ethnicity = ethnicity
        self.category = category
        self.region = region
        self.imageUrl = imageUrl
        self.description = description
        self.contentBlocks = contentBlocks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        projectName = try container.decodeIfPresent(String.self, forKey: .projectName)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        ethnicity = try container.decodeIfPresent(String.self, forKey: .ethnicity)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        contentBlocks = try container.decodeIfPresent([ContentBlockDTO].self, forKey: .contentBlocks) ?? []
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
