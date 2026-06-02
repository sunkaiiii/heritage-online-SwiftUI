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
    let banners: [HomeBannerDTO]?
    let articles: [ArticleSummaryDTO]?
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
    let contentBlocks: [ContentBlockDTO]?
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
    let contentBlocks: [ContentBlockDTO]?
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
    let contentBlocks: [ContentBlockDTO]?
}

/// 详情 Context DTO
struct DetailContextDTO: Decodable, Sendable {
    let related: [RelatedItemDTO]?
    let recommendations: [RelatedItemDTO]?
    let semanticRecommendations: [RelatedItemDTO]?
    let collections: [CollectionRefDTO]?
    let exploreTopics: [ExploreTopicRefDTO]?
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
