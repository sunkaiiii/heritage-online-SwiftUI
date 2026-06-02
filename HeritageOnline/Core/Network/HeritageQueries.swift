import Foundation

/// 文章查询参数
/// 完全对齐 Android ArticleQuery
struct ArticleQuery: Sendable {
    let category: ArticleCategory
    let page: Int
    let pageSize: Int
    let year: Int?
    let keywords: String?

    init(
        category: ArticleCategory = .news,
        page: Int = 1,
        pageSize: Int = 20,
        year: Int? = nil,
        keywords: String? = nil
    ) {
        self.category = category
        self.page = page
        self.pageSize = pageSize
        self.year = year
        self.keywords = keywords
    }
}

/// 文章分类
enum ArticleCategory: String, Sendable {
    case news
    case forum
    case specialTopic

    /// wire value
    var wireName: String { rawValue }
}

/// 名录查询参数
/// 完全对齐 Android DirectoryItemQuery
struct DirectoryItemQuery: Sendable {
    let kind: DirectoryItemKind
    let page: Int
    let pageSize: Int
    let keywords: String?
    let region: String?
    let category: String?
    let year: Int?
    let listType: String?

    init(
        kind: DirectoryItemKind = .nationalProject,
        page: Int = 1,
        pageSize: Int = 20,
        keywords: String? = nil,
        region: String? = nil,
        category: String? = nil,
        year: Int? = nil,
        listType: String? = nil
    ) {
        self.kind = kind
        self.page = page
        self.pageSize = pageSize
        self.keywords = keywords
        self.region = region
        self.category = category
        self.year = year
        self.listType = listType
    }
}

/// 名录种类
enum DirectoryItemKind: String, Sendable {
    case nationalProject
    case culturalEcoZone
    case productiveProtectionBase
    case unescoEntry
    case chinaUnescoEntry
    case contractingState

    /// wire value
    var wireName: String { rawValue }
}

/// 传承人查询参数
/// 完全对齐 Android InheritorQuery
struct InheritorQuery: Sendable {
    let page: Int
    let pageSize: Int
    let keywords: String?
    let region: String?
    let category: String?
    let year: Int?
    let gender: String?

    init(
        page: Int = 1,
        pageSize: Int = 20,
        keywords: String? = nil,
        region: String? = nil,
        category: String? = nil,
        year: Int? = nil,
        gender: String? = nil
    ) {
        self.page = page
        self.pageSize = pageSize
        self.keywords = keywords
        self.region = region
        self.category = category
        self.year = year
        self.gender = gender
    }
}

/// 搜索查询参数
/// 完全对齐 Android SearchV2Query
struct SearchV2Query: Sendable {
    let keywords: String
    let types: Set<SearchResultType>
    let page: Int
    let pageSize: Int
    let region: String?
    let category: String?
    let year: Int?
    let kind: DirectoryItemKind?
    let hasImage: Bool?

    init(
        keywords: String,
        types: Set<SearchResultType> = [],
        page: Int = 1,
        pageSize: Int = 20,
        region: String? = nil,
        category: String? = nil,
        year: Int? = nil,
        kind: DirectoryItemKind? = nil,
        hasImage: Bool? = nil
    ) {
        self.keywords = keywords
        self.types = types
        self.page = page
        self.pageSize = pageSize
        self.region = region
        self.category = category
        self.year = year
        self.kind = kind
        self.hasImage = hasImage
    }
}

/// 搜索结果类型
enum SearchResultType: String, Sendable {
    case article
    case directoryItem
    case inheritor

    /// wire value
    var wireName: String { rawValue }
}

/// 时间线查询参数
/// 完全对齐 Android TimelineV2Query
struct TimelineV2Query: Sendable {
    let year: Int?
    let types: Set<SearchResultType>
    let page: Int
    let pageSize: Int
    let category: String?
    let region: String?
    let kind: DirectoryItemKind?
    let hasImage: Bool?

    init(
        year: Int? = nil,
        types: Set<SearchResultType> = [],
        page: Int = 1,
        pageSize: Int = 20,
        category: String? = nil,
        region: String? = nil,
        kind: DirectoryItemKind? = nil,
        hasImage: Bool? = nil
    ) {
        self.year = year
        self.types = types
        self.page = page
        self.pageSize = pageSize
        self.category = category
        self.region = region
        self.kind = kind
        self.hasImage = hasImage
    }
}

/// 主题库地区排序
enum TaxonomyRegionSort: String, Sendable {
    case total
    case directoryItem
    case inheritor

    /// wire value
    var wireName: String { rawValue }
}

/// 发现随便看看查询参数
struct DiscoverySerendipityQuery: Sendable {
    let type: SearchResultType
    let hasImage: Bool?
    let region: String?
    let category: String?

    init(
        type: SearchResultType = .directoryItem,
        hasImage: Bool? = nil,
        region: String? = nil,
        category: String? = nil
    ) {
        self.type = type
        self.hasImage = hasImage
        self.region = region
        self.category = category
    }
}

/// 发现深度探索查询参数
struct DiscoveryDeepDiveQuery: Sendable {
    let seedType: SearchResultType
    let seedId: String
    let limit: Int

    init(
        seedType: SearchResultType,
        seedId: String,
        limit: Int = 10
    ) {
        self.seedType = seedType
        self.seedId = seedId
        self.limit = limit
    }
}

/// 综合推荐查询参数
struct BlendedRecommendationQuery: Sendable {
    let type: SearchResultType
    let id: String
    let limit: Int
    let ruleWeight: Double
    let semanticWeight: Double
    let sameCategoryWeight: Double
    let sameRegionWeight: Double
    let diversify: Bool

    init(
        type: SearchResultType,
        id: String,
        limit: Int = 10,
        ruleWeight: Double = 1.0,
        semanticWeight: Double = 1.0,
        sameCategoryWeight: Double = 1.0,
        sameRegionWeight: Double = 1.0,
        diversify: Bool = true
    ) {
        self.type = type
        self.id = id
        self.limit = limit
        self.ruleWeight = ruleWeight
        self.semanticWeight = semanticWeight
        self.sameCategoryWeight = sameCategoryWeight
        self.sameRegionWeight = sameRegionWeight
        self.diversify = diversify
    }
}
