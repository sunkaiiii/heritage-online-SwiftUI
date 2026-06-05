import Foundation

/// 媒体资源 DTO
/// 完全对齐 Android MediaAssetDto
struct MediaAssetDTO: Codable, Sendable {
    let sourceUrl: String?
    let originalUrl: String?
    let displayUrl: String?
    let thumbnailUrl: String?
    let altText: String?

    init(
        sourceUrl: String?,
        originalUrl: String?,
        displayUrl: String?,
        thumbnailUrl: String?,
        altText: String?
    ) {
        self.sourceUrl = sourceUrl
        self.originalUrl = originalUrl
        self.displayUrl = displayUrl
        self.thumbnailUrl = thumbnailUrl
        self.altText = altText
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        originalUrl = try container.decodeIfPresent(String.self, forKey: .originalUrl)
        displayUrl = try container.decodeIfPresent(String.self, forKey: .displayUrl)
        thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        altText = try container.decodeIfPresent(String.self, forKey: .altText)
    }
}

/// 错误详情 DTO
/// 完全对齐 Android ProblemDetailsDto
struct ProblemDetailsDTO: Codable, Sendable {
    let type: String?
    let title: String?
    let status: Int?
    let detail: String?
    let instance: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        instance = try container.decodeIfPresent(String.self, forKey: .instance)
    }
}

/// Facet Bucket DTO
/// 完全对齐 Android FacetBucketDto
struct FacetBucketDTO: Codable, Sendable {
    let key: String?
    let count: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
    }
}

/// 探索主题链接 DTO
/// 完全对齐 Android ExploreTopicLinkDto
struct ExploreTopicLinkDTO: Codable, Sendable {
    let type: String?
    let key: String?
    let title: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}

// MARK: - 分页结果 DTO

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

// MARK: - 首页 DTO

struct HomeBannerDTO: Decodable, Sendable {
    let id: String?
    let sortOrder: Int?
    let targetUrl: String?
    let displayImage: MediaAssetDTO?
    let mobileImage: MediaAssetDTO?
    let desktopImage: MediaAssetDTO?
}

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

// MARK: - 详情 Context DTO

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
        // 使用容错解码：单个 item 解码失败时跳过，不影响其他 section
        related = container.decodeLossyArrayIfPresent(RelatedItemDTO.self, forKey: .related)
        recommendations = container.decodeLossyArrayIfPresent(RelatedItemDTO.self, forKey: .recommendations)
        semanticRecommendations = container.decodeLossyArrayIfPresent(RelatedItemDTO.self, forKey: .semanticRecommendations)
        collections = container.decodeLossyArrayIfPresent(CollectionRefDTO.self, forKey: .collections)
        exploreTopics = container.decodeLossyArrayIfPresent(ExploreTopicRefDTO.self, forKey: .exploreTopics)
        graph = container.decodeLossyArrayIfPresent(GraphEdgeDTO.self, forKey: .graph)
    }
}

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

struct CollectionRefDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let type: String?
}

struct ExploreTopicRefDTO: Decodable, Sendable {
    let type: String?
    let key: String?
    let title: String?
}

struct GraphEdgeDTO: Decodable, Sendable {
    let fromId: String?
    let fromType: String?
    let fromTitle: String?
    let toId: String?
    let toType: String?
    let toTitle: String?
    let relation: String?
}

