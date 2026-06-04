import Foundation

// MARK: - 主题库 DTO

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

struct TaxonomyRegionCountDTO: Decodable, Sendable {
    let region: String
    let count: Int
}

struct TaxonomyCategoryCountDTO: Decodable, Sendable {
    let category: String
    let count: Int
}

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

