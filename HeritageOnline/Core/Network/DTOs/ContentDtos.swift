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

// MARK: - 文章 DTO

struct ArticleSummaryDTO: Decodable, Sendable {
    let id: String?
    let category: String?
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?
}

struct ArticleDetailDTO: Decodable, Sendable {
    let id: String?
    let sourceId: String?
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
        case id, sourceId, category, title, summary, publishedAt, coverImage, sourceUrl
        case sourceName, author, editor, contentBlocks, relatedArticles
    }

    init(id: String?, sourceId: String? = nil, category: String?, title: String?, summary: String?, publishedAt: String?, coverImage: MediaAssetDTO?, sourceUrl: String?, sourceName: String?, author: String?, editor: String?, contentBlocks: [ArticleContentBlockDTO], relatedArticles: [ArticleReferenceDTO]) {
        self.id = id
        self.sourceId = sourceId
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
        sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId)
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

// MARK: - 名录 DTO

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

struct DirectoryItemDetailDTO: Decodable, Sendable {
    let id: String?
    let sourceId: String?
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
        case id, sourceId, kind, title, summary, category, region, projectCode, batch, publishedYear
        case listType, nominationType, protectionUnit, coverImage, sourceUrl
        case gallery, contentBlocks, relatedProjects, relatedInheritors, relatedDocuments
    }

    init(id: String?, sourceId: String? = nil, kind: String?, title: String?, summary: String?, category: String?, region: String?, projectCode: String?, batch: String?, publishedYear: Int?, listType: String?, nominationType: String?, protectionUnit: String?, coverImage: MediaAssetDTO?, sourceUrl: String?, gallery: [MediaAssetDTO], contentBlocks: [ArticleContentBlockDTO], relatedProjects: [DirectoryReferenceDTO], relatedInheritors: [DirectoryReferenceDTO], relatedDocuments: [DirectoryReferenceDTO]) {
        self.id = id
        self.sourceId = sourceId
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
        sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId)
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

// MARK: - 传承人 DTO

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

struct InheritorDetailDTO: Decodable, Sendable {
    let id: String?
    let sourceId: String?
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
        case id, sourceId, name, gender, birthDateText, ethnicity, category, projectCode, projectName
        case region, batch, description, coverImage, sourceUrl
        case contentBlocks, relatedProjects, relatedInheritors
    }

    init(id: String?, sourceId: String? = nil, name: String?, gender: String?, birthDateText: String?, ethnicity: String?, category: String?, projectCode: String?, projectName: String?, region: String?, batch: String?, description: String?, coverImage: MediaAssetDTO?, sourceUrl: String?, contentBlocks: [ArticleContentBlockDTO], relatedProjects: [DirectoryReferenceDTO], relatedInheritors: [DirectoryReferenceDTO]) {
        self.id = id
        self.sourceId = sourceId
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
        sourceId = try container.decodeIfPresent(String.self, forKey: .sourceId)
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

// MARK: - Digest DTO

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

struct DigestFactDTO: Decodable, Sendable {
    let label: String
    let value: String
}

// MARK: - 综合推荐 DTO

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

