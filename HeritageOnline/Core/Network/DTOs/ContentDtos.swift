import Foundation

/// 文章内容块类型
/// 完全对齐 Android ArticleContentBlockType
enum ArticleContentBlockType: String, Codable, Sendable {
    case text
    case image
    case heading
}

/// 文章内容块 DTO
/// 完全对齐 Android ArticleContentBlockDto
struct ArticleContentBlockDTO: Codable, Sendable {
    let type: ArticleContentBlockType
    let text: String?
    let image: MediaAssetDTO?

    init(
        type: ArticleContentBlockType,
        text: String?,
        image: MediaAssetDTO?
    ) {
        self.type = type
        self.text = text
        self.image = image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(ArticleContentBlockType.self, forKey: .type) ?? .text
        text = try container.decodeIfPresent(String.self, forKey: .text)
        image = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .image)
    }
}

/// 文章引用 DTO
/// 完全对齐 Android ArticleReferenceDto
struct ArticleReferenceDTO: Codable, Sendable {
    let title: String?
    let detailUrl: String?
    let sourceId: String?
    let publishedAt: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        detailUrl = try container.decodeIfPresent(String.self, forKey: .detailUrl)
        sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId)
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
    }
}

/// 名录统计维度
/// 完全对齐 Android DirectoryStatisticDimension
enum DirectoryStatisticDimension: String, Codable, Sendable {
    case publishedYear
    case category
    case region
    case batch
    case listType
    case nominationType
    case protectionUnit

    /// wire value
    var wireName: String { rawValue }
}

/// 名录统计概览 DTO
/// 完全对齐 Android DirectoryStatisticsOverviewDto
struct DirectoryStatisticsOverviewDTO: Codable, Sendable {
    let kind: String?
    let total: Int
    let generatedAt: String?
    let dimensions: [DirectoryStatisticDimensionDTO]

    init(
        kind: String? = nil,
        total: Int = 0,
        generatedAt: String? = nil,
        dimensions: [DirectoryStatisticDimensionDTO] = []
    ) {
        self.kind = kind
        self.total = total
        self.generatedAt = generatedAt
        self.dimensions = dimensions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
        dimensions = try container.decodeIfPresent([DirectoryStatisticDimensionDTO].self, forKey: .dimensions) ?? []
    }
}

/// 名录统计维度 DTO
/// 完全对齐 Android DirectoryStatisticDimensionDto
struct DirectoryStatisticDimensionDTO: Codable, Sendable {
    let dimension: String?
    let items: [DirectoryStatisticItemDTO]

    init(
        dimension: String? = nil,
        items: [DirectoryStatisticItemDTO] = []
    ) {
        self.dimension = dimension
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dimension = try container.decodeIfPresent(String.self, forKey: .dimension)
        items = try container.decodeIfPresent([DirectoryStatisticItemDTO].self, forKey: .items) ?? []
    }
}

/// 名录统计项 DTO
/// 完全对齐 Android DirectoryStatisticItemDto
struct DirectoryStatisticItemDTO: Codable, Sendable {
    let key: String?
    let name: String?
    let value: Int

    init(
        key: String? = nil,
        name: String? = nil,
        value: Int = 0
    ) {
        self.key = key
        self.name = name
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
    }
}

/// 名录引用 DTO
/// 完全对齐 Android DirectoryReferenceDto
struct DirectoryReferenceDTO: Codable, Sendable {
    let title: String?
    let detailUrl: String?
    let sourceId: String?
    let kind: String?
    let category: String?
    let region: String?
    let publishedYear: Int?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        detailUrl = try container.decodeIfPresent(String.self, forKey: .detailUrl)
        sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        publishedYear = try container.decodeIfPresent(Int.self, forKey: .publishedYear)
    }
}

/// 首页 Feed 摘要 DTO
/// 完全对齐 Android HomeFeedSummaryDto
struct HomeFeedSummaryDTO: Codable, Sendable {
    let totalArticles: Int
    let totalDirectoryItems: Int
    let totalInheritors: Int
    let directoryKindCounts: [String: Int]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        totalArticles = try container.decodeIfPresent(Int.self, forKey: .totalArticles) ?? 0
        totalDirectoryItems = try container.decodeIfPresent(Int.self, forKey: .totalDirectoryItems) ?? 0
        totalInheritors = try container.decodeIfPresent(Int.self, forKey: .totalInheritors) ?? 0
        directoryKindCounts = try container.decodeIfPresent([String: Int].self, forKey: .directoryKindCounts) ?? [:]
    }
}
