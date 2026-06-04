import Foundation

// MARK: - 搜索 DTO

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

struct SearchFacetsDTO: Decodable, Sendable {
    let types: [FacetBucketDTO]?
    let categories: [FacetBucketDTO]?
    let regions: [FacetBucketDTO]?
    let years: [FacetBucketDTO]?
    let kinds: [FacetBucketDTO]?
}

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

struct SearchSuggestionDTO: Decodable, Sendable {
    let text: String?
    let type: String?
}

// MARK: - 时间线 DTO

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

struct TimelineFacetsDTO: Decodable, Sendable {
    let types: [FacetBucketDTO]?
    let categories: [FacetBucketDTO]?
    let regions: [FacetBucketDTO]?
}

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

