import Foundation

// MARK: - 对比 DTO

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

struct CompareSummaryDTO: Decodable, Sendable {
    let winnerByDirectoryItems: String?
    let winnerByInheritors: String?
    let winnerByArticles: String?
    let winnerByTotal: String?
}

