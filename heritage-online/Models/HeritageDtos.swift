import Foundation

// MARK: - Paged Result

struct PagedResult<T: Codable>: Codable {
    let items: [T]
    let page: Int
    let pageSize: Int
    let hasMore: Bool
    let total: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([T].self, forKey: .items) ?? []
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        pageSize = try container.decodeIfPresent(Int.self, forKey: .pageSize) ?? 20
        hasMore = try container.decodeIfPresent(Bool.self, forKey: .hasMore) ?? false
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
    }
}

// MARK: - Media Asset

struct MediaAssetDto: Codable, Equatable {
    let sourceUrl: String?
    let originalUrl: String?
    let displayUrl: String?
    let thumbnailUrl: String?
    let altText: String?

    var previewUrl: String? {
        displayUrl ?? thumbnailUrl ?? originalUrl ?? sourceUrl
    }
}

// MARK: - Article

enum ArticleCategory: String, Codable, CaseIterable, Hashable {
    case news = "news"
    case forum = "forum"
    case specialTopic = "specialTopic"

    var label: String {
        switch self {
        case .news: return String(localized: "category_news")
        case .forum: return String(localized: "category_forum")
        case .specialTopic: return String(localized: "category_special_topic")
        }
    }
}

enum ArticleContentBlockType: String, Codable, Hashable {
    case text = "text"
    case image = "image"
    case heading = "heading"
}

struct ArticleContentBlockDto: Codable {
    let type: ArticleContentBlockType
    let text: String?
    let image: MediaAssetDto?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(ArticleContentBlockType.self, forKey: .type) ?? .text
        text = try container.decodeIfPresent(String.self, forKey: .text)
        image = try container.decodeIfPresent(MediaAssetDto.self, forKey: .image)
    }
}

struct ArticleReferenceDto: Codable {
    let title: String?
    let detailUrl: String?
    let sourceId: String?
    let publishedAt: String?
}

struct ArticleSummaryDto: Codable, Identifiable {
    var id: String { _id ?? sourceUrl ?? UUID().uuidString }
    private let _id: String?

    let category: ArticleCategory
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImage: MediaAssetDto?
    let sourceUrl: String?

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case category, title, summary, publishedAt, coverImage, sourceUrl
    }
}

struct ArticleDetailDto: Codable {
    let id: String?
    let category: ArticleCategory
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImage: MediaAssetDto?
    let sourceUrl: String?
    let sourceName: String?
    let author: String?
    let editor: String?
    let contentBlocks: [ArticleContentBlockDto]
    let relatedArticles: [ArticleReferenceDto]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        category = try container.decodeIfPresent(ArticleCategory.self, forKey: .category) ?? .news
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        coverImage = try container.decodeIfPresent(MediaAssetDto.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        sourceName = try container.decodeIfPresent(String.self, forKey: .sourceName)
        author = try container.decodeIfPresent(String.self, forKey: .author)
        editor = try container.decodeIfPresent(String.self, forKey: .editor)
        contentBlocks = try container.decodeIfPresent([ArticleContentBlockDto].self, forKey: .contentBlocks) ?? []
        relatedArticles = try container.decodeIfPresent([ArticleReferenceDto].self, forKey: .relatedArticles) ?? []
    }
}

// MARK: - Directory Item

enum DirectoryItemKind: String, Codable, CaseIterable, Hashable {
    case nationalProject = "nationalProject"
    case culturalEcoZone = "culturalEcoZone"
    case productiveProtectionBase = "productiveProtectionBase"
    case unescoEntry = "unescoEntry"
    case chinaUnescoEntry = "chinaUnescoEntry"
    case contractingState = "contractingState"

    var label: String {
        switch self {
        case .nationalProject: return String(localized: "directory_kind_national_project")
        case .culturalEcoZone: return String(localized: "directory_kind_cultural_eco_zone")
        case .productiveProtectionBase: return String(localized: "directory_kind_productive_protection_base")
        case .unescoEntry: return String(localized: "directory_kind_unesco_entry")
        case .chinaUnescoEntry: return String(localized: "directory_kind_china_unesco_entry")
        case .contractingState: return String(localized: "directory_kind_contracting_state")
        }
    }
}

enum DirectoryStatisticDimension: String, Codable {
    case publishedYear = "publishedYear"
    case category = "category"
    case region = "region"
    case batch = "batch"
    case listType = "listType"
    case nominationType = "nominationType"
    case protectionUnit = "protectionUnit"
}

struct DirectoryStatisticsOverviewDto: Codable {
    let kind: String?
    let total: Int
    let generatedAt: String?
    let dimensions: [DirectoryStatisticDimensionDto]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
        dimensions = try container.decodeIfPresent([DirectoryStatisticDimensionDto].self, forKey: .dimensions) ?? []
    }
}

struct DirectoryStatisticDimensionDto: Codable {
    let dimension: String?
    let items: [DirectoryStatisticItemDto]
}

struct DirectoryStatisticItemDto: Codable {
    let key: String?
    let name: String?
    let value: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
    }
}

struct DirectoryReferenceDto: Codable {
    let title: String?
    let detailUrl: String?
    let sourceId: String?
    let kind: String?
    let category: String?
    let region: String?
    let publishedYear: Int?

    var isInheritorReference: Bool {
        kind?.lowercased() == "inheritor" ||
        detailUrl?.contains("/ccr_detail/") == true
    }
}

struct DirectoryItemSummaryDto: Codable, Identifiable {
    var id: String { _id ?? sourceUrl ?? UUID().uuidString }
    private let _id: String?

    let kind: DirectoryItemKind
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let projectCode: String?
    let batch: String?
    let publishedYear: Int?
    let listType: String?
    let coverImage: MediaAssetDto?
    let sourceUrl: String?

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case kind, title, summary, category, region, projectCode, batch, publishedYear, listType, coverImage, sourceUrl
    }
}

struct DirectoryItemDetailDto: Codable {
    let id: String?
    let kind: DirectoryItemKind
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let projectCode: String?
    let batch: String?
    let publishedYear: Int?
    let listType: String?
    let coverImage: MediaAssetDto?
    let sourceUrl: String?
    let nominationType: String?
    let protectionUnit: String?
    let gallery: [MediaAssetDto]
    let contentBlocks: [ArticleContentBlockDto]
    let relatedProjects: [DirectoryReferenceDto]
    let relatedInheritors: [DirectoryReferenceDto]
    let relatedDocuments: [DirectoryReferenceDto]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        kind = try container.decodeIfPresent(DirectoryItemKind.self, forKey: .kind) ?? .nationalProject
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        projectCode = try container.decodeIfPresent(String.self, forKey: .projectCode)
        batch = try container.decodeIfPresent(String.self, forKey: .batch)
        publishedYear = try container.decodeIfPresent(Int.self, forKey: .publishedYear)
        listType = try container.decodeIfPresent(String.self, forKey: .listType)
        coverImage = try container.decodeIfPresent(MediaAssetDto.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        nominationType = try container.decodeIfPresent(String.self, forKey: .nominationType)
        protectionUnit = try container.decodeIfPresent(String.self, forKey: .protectionUnit)
        gallery = try container.decodeIfPresent([MediaAssetDto].self, forKey: .gallery) ?? []
        contentBlocks = try container.decodeIfPresent([ArticleContentBlockDto].self, forKey: .contentBlocks) ?? []
        relatedProjects = try container.decodeIfPresent([DirectoryReferenceDto].self, forKey: .relatedProjects) ?? []
        relatedInheritors = try container.decodeIfPresent([DirectoryReferenceDto].self, forKey: .relatedInheritors) ?? []
        relatedDocuments = try container.decodeIfPresent([DirectoryReferenceDto].self, forKey: .relatedDocuments) ?? []
    }
}

// MARK: - Inheritor

struct InheritorSummaryDto: Codable, Identifiable {
    var id: String { _id ?? sourceUrl ?? UUID().uuidString }
    private let _id: String?

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
    let coverImage: MediaAssetDto?
    let sourceUrl: String?

    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case name, gender, birthDateText, ethnicity, category, projectCode, projectName, region, batch, description, coverImage, sourceUrl
    }
}

struct InheritorDetailDto: Codable {
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
    let coverImage: MediaAssetDto?
    let sourceUrl: String?
    let contentBlocks: [ArticleContentBlockDto]
    let relatedProjects: [DirectoryReferenceDto]
    let relatedInheritors: [DirectoryReferenceDto]

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
        coverImage = try container.decodeIfPresent(MediaAssetDto.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        contentBlocks = try container.decodeIfPresent([ArticleContentBlockDto].self, forKey: .contentBlocks) ?? []
        relatedProjects = try container.decodeIfPresent([DirectoryReferenceDto].self, forKey: .relatedProjects) ?? []
        relatedInheritors = try container.decodeIfPresent([DirectoryReferenceDto].self, forKey: .relatedInheritors) ?? []
    }
}

// MARK: - Home Banner

struct HomeBannerDto: Codable {
    let id: String?
    let sortOrder: Int
    let targetUrl: String?
    let displayImage: MediaAssetDto?
    let mobileImage: MediaAssetDto?
    let desktopImage: MediaAssetDto?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        sortOrder = try container.decodeIfPresent(Int.self, forKey: .sortOrder) ?? 0
        targetUrl = try container.decodeIfPresent(String.self, forKey: .targetUrl)
        displayImage = try container.decodeIfPresent(MediaAssetDto.self, forKey: .displayImage)
        mobileImage = try container.decodeIfPresent(MediaAssetDto.self, forKey: .mobileImage)
        desktopImage = try container.decodeIfPresent(MediaAssetDto.self, forKey: .desktopImage)
    }
}
