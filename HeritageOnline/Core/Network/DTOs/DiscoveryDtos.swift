import Foundation

// MARK: - 发现页 DTO
// 完全对齐 Android DiscoveryDtos.kt 和 ExploreDtos.kt

/// 发现项 DTO
/// 对齐 Android DiscoveryItemDto
struct DiscoveryItemDTO: Decodable, Sendable {
    let id: String?
    let type: String
    let title: String
    let summary: String?
    let category: String?
    let kind: String?
    let region: String?
    let publishedAt: String?
    let publishedYear: Int?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String

    enum CodingKeys: String, CodingKey {
        case id, type, title, summary, category, kind, region
        case publishedAt, publishedYear, coverImage, sourceUrl
    }

    init(id: String?, type: String, title: String, summary: String?, category: String?, kind: String?, region: String?, publishedAt: String?, publishedYear: Int?, coverImage: MediaAssetDTO?, sourceUrl: String) {
        self.id = id
        self.type = type
        self.title = title
        self.summary = summary
        self.category = category
        self.kind = kind
        self.region = region
        self.publishedAt = publishedAt
        self.publishedYear = publishedYear
        self.coverImage = coverImage
        self.sourceUrl = sourceUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        publishedYear = try container.decodeIfPresent(Int.self, forKey: .publishedYear)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl) ?? ""
    }
}

/// 今日发现 DTO
/// 对齐 Android DiscoveryTodayDto
struct DiscoveryTodayDTO: Decodable, Sendable {
    let featuredDirectoryItem: DiscoveryItemDTO?
    let featuredInheritor: DiscoveryItemDTO?
    let articles: [DiscoveryItemDTO]
    let date: String

    enum CodingKeys: String, CodingKey {
        case featuredDirectoryItem, featuredInheritor, articles, date
    }

    init(featuredDirectoryItem: DiscoveryItemDTO?, featuredInheritor: DiscoveryItemDTO?, articles: [DiscoveryItemDTO], date: String) {
        self.featuredDirectoryItem = featuredDirectoryItem
        self.featuredInheritor = featuredInheritor
        self.articles = articles
        self.date = date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        featuredDirectoryItem = try container.decodeIfPresent(DiscoveryItemDTO.self, forKey: .featuredDirectoryItem)
        featuredInheritor = try container.decodeIfPresent(DiscoveryItemDTO.self, forKey: .featuredInheritor)
        articles = try container.decodeIfPresent([DiscoveryItemDTO].self, forKey: .articles) ?? []
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
    }
}

/// 发现区块 DTO
/// 对齐 Android DiscoverySectionDto
struct DiscoverySectionDTO: Decodable, Sendable {
    let id: String
    let title: String
    let subtitle: String?
    let items: [DiscoveryItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, items
    }

    init(id: String, title: String, subtitle: String?, items: [DiscoveryItemDTO]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        items = try container.decodeIfPresent([DiscoveryItemDTO].self, forKey: .items) ?? []
    }
}

/// 本周精选 DTO
/// 对齐 Android DiscoveryWeeklyDto
struct DiscoveryWeeklyDTO: Decodable, Sendable {
    let weekId: String
    let sections: [DiscoverySectionDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case weekId, sections, generatedAt
    }

    init(weekId: String, sections: [DiscoverySectionDTO], generatedAt: String?) {
        self.weekId = weekId
        self.sections = sections
        self.generatedAt = generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weekId = try container.decodeIfPresent(String.self, forKey: .weekId) ?? ""
        sections = try container.decodeIfPresent([DiscoverySectionDTO].self, forKey: .sections) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 趋势内容 DTO
/// 对齐 Android DiscoveryTrendingDto
struct DiscoveryTrendingDTO: Decodable, Sendable {
    let items: [DiscoveryItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case items, generatedAt
    }

    init(items: [DiscoveryItemDTO], generatedAt: String?) {
        self.items = items
        self.generatedAt = generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decodeIfPresent([DiscoveryItemDTO].self, forKey: .items) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 深度探索 DTO
/// 对齐 Android DiscoveryDeepDiveDto
struct DiscoveryDeepDiveDTO: Decodable, Sendable {
    let seed: DiscoveryItemDTO?
    let related: [DiscoveryItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case seed, related, generatedAt
    }

    init(seed: DiscoveryItemDTO?, related: [DiscoveryItemDTO], generatedAt: String?) {
        self.seed = seed
        self.related = related
        self.generatedAt = generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seed = try container.decodeIfPresent(DiscoveryItemDTO.self, forKey: .seed)
        related = try container.decodeIfPresent([DiscoveryItemDTO].self, forKey: .related) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

// MARK: - 探索相关 DTO

/// 探索主题信息 DTO
/// 对齐 Android ExploreTopicInfoDto
struct ExploreTopicInfoDTO: Decodable, Sendable {
    let type: String?
    let key: String?
    let title: String?
    let subtitle: String?

    enum CodingKeys: String, CodingKey {
        case type, key, title, subtitle
    }

    init(type: String?, key: String?, title: String?, subtitle: String?) {
        self.type = type
        self.key = key
        self.title = title
        self.subtitle = subtitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
    }
}

/// 探索主题项 DTO
/// 对齐 Android ExploreTopicItemDto
struct ExploreTopicItemDTO: Decodable, Sendable {
    let id: String?
    let type: String?
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let kind: String?
    let year: Int?
    let count: Int?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, type, title, summary, category, region, kind
        case year, count, coverImage, sourceUrl
    }

    init(id: String?, type: String?, title: String?, summary: String?, category: String?, region: String?, kind: String?, year: Int?, count: Int?, coverImage: MediaAssetDTO?, sourceUrl: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.summary = summary
        self.category = category
        self.region = region
        self.kind = kind
        self.year = year
        self.count = count
        self.coverImage = coverImage
        self.sourceUrl = sourceUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        kind = try container.decodeIfPresent(String.self, forKey: .kind)
        year = try container.decodeIfPresent(Int.self, forKey: .year)
        count = try container.decodeIfPresent(Int.self, forKey: .count)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}

/// 探索主题区块 DTO
/// 对齐 Android ExploreTopicSectionDto
struct ExploreTopicSectionDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let items: [ExploreTopicItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, items
    }

    init(id: String?, title: String?, subtitle: String?, items: [ExploreTopicItemDTO]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        items = try container.decodeIfPresent([ExploreTopicItemDTO].self, forKey: .items) ?? []
    }
}

/// 探索主题统计 DTO
/// 对齐 Android ExploreTopicStatDto
struct ExploreTopicStatDTO: Decodable, Sendable {
    let name: String?
    let value: Int

    enum CodingKeys: String, CodingKey {
        case name, value
    }

    init(name: String?, value: Int) {
        self.name = name
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
    }
}

/// 探索主题详情 DTO
/// 对齐 Android ExploreTopicV2Dto
struct ExploreTopicV2DTO: Decodable, Sendable {
    let topic: ExploreTopicInfoDTO?
    let stats: [ExploreTopicStatDTO]
    let sections: [ExploreTopicSectionDTO]
    let relatedTopics: [ExploreTopicLinkDTO]
    let timeline: [ExploreTopicItemDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case topic, stats, sections, relatedTopics, timeline, generatedAt
    }

    init(topic: ExploreTopicInfoDTO?, stats: [ExploreTopicStatDTO], sections: [ExploreTopicSectionDTO], relatedTopics: [ExploreTopicLinkDTO], timeline: [ExploreTopicItemDTO], generatedAt: String?) {
        self.topic = topic
        self.stats = stats
        self.sections = sections
        self.relatedTopics = relatedTopics
        self.timeline = timeline
        self.generatedAt = generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        topic = try container.decodeIfPresent(ExploreTopicInfoDTO.self, forKey: .topic)
        stats = try container.decodeIfPresent([ExploreTopicStatDTO].self, forKey: .stats) ?? []
        sections = try container.decodeIfPresent([ExploreTopicSectionDTO].self, forKey: .sections) ?? []
        relatedTopics = try container.decodeIfPresent([ExploreTopicLinkDTO].self, forKey: .relatedTopics) ?? []
        timeline = try container.decodeIfPresent([ExploreTopicItemDTO].self, forKey: .timeline) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

/// 探索索引 DTO
/// 对齐 Android ExploreIndexDto
struct ExploreIndexDTO: Decodable, Sendable {
    let regions: [ExploreTopicInfoDTO]
    let categories: [ExploreTopicInfoDTO]
    let years: [ExploreTopicInfoDTO]

    enum CodingKeys: String, CodingKey {
        case regions, categories, years
    }

    init(regions: [ExploreTopicInfoDTO], categories: [ExploreTopicInfoDTO], years: [ExploreTopicInfoDTO]) {
        self.regions = regions
        self.categories = categories
        self.years = years
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        regions = try container.decodeIfPresent([ExploreTopicInfoDTO].self, forKey: .regions) ?? []
        categories = try container.decodeIfPresent([ExploreTopicInfoDTO].self, forKey: .categories) ?? []
        years = try container.decodeIfPresent([ExploreTopicInfoDTO].self, forKey: .years) ?? []
    }
}

// MARK: - 学习路径 DTO

/// 学习路径步骤 DTO
/// 对齐 Android LearningPathStepDto
struct LearningPathStepDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let topic: ExploreTopicInfoDTO?
    let items: [ExploreTopicItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, topic, items
    }

    init(id: String?, title: String?, subtitle: String?, topic: ExploreTopicInfoDTO?, items: [ExploreTopicItemDTO]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.topic = topic
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        topic = try container.decodeIfPresent(ExploreTopicInfoDTO.self, forKey: .topic)
        items = try container.decodeIfPresent([ExploreTopicItemDTO].self, forKey: .items) ?? []
    }
}

/// 学习路径 DTO
/// 对齐 Android LearningPathDto
struct LearningPathDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let topics: [ExploreTopicLinkDTO]
    let description: String?
    let coverImage: String?
    let estimatedItemCount: Int
    let stepCount: Int
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, topics, description, coverImage
        case estimatedItemCount, stepCount, tags
    }

    init(id: String?, title: String?, subtitle: String?, topics: [ExploreTopicLinkDTO], description: String?, coverImage: String?, estimatedItemCount: Int, stepCount: Int, tags: [String]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.topics = topics
        self.description = description
        self.coverImage = coverImage
        self.estimatedItemCount = estimatedItemCount
        self.stepCount = stepCount
        self.tags = tags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        topics = try container.decodeIfPresent([ExploreTopicLinkDTO].self, forKey: .topics) ?? []
        description = try container.decodeIfPresent(String.self, forKey: .description)
        coverImage = try container.decodeIfPresent(String.self, forKey: .coverImage)
        estimatedItemCount = try container.decodeIfPresent(Int.self, forKey: .estimatedItemCount) ?? 0
        stepCount = try container.decodeIfPresent(Int.self, forKey: .stepCount) ?? 0
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
}

/// 学习路径详情 DTO
/// 对齐 Android LearningPathDetailDto
struct LearningPathDetailDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let description: String?
    let tags: [String]
    let steps: [LearningPathStepDTO]
    let featuredItems: [ExploreTopicItemDTO]
    let relatedTopics: [ExploreTopicLinkDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, description, tags, steps
        case featuredItems, relatedTopics, generatedAt
    }

    init(id: String?, title: String?, subtitle: String?, description: String?, tags: [String], steps: [LearningPathStepDTO], featuredItems: [ExploreTopicItemDTO], relatedTopics: [ExploreTopicLinkDTO], generatedAt: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.tags = tags
        self.steps = steps
        self.featuredItems = featuredItems
        self.relatedTopics = relatedTopics
        self.generatedAt = generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        steps = try container.decodeIfPresent([LearningPathStepDTO].self, forKey: .steps) ?? []
        featuredItems = try container.decodeIfPresent([ExploreTopicItemDTO].self, forKey: .featuredItems) ?? []
        relatedTopics = try container.decodeIfPresent([ExploreTopicLinkDTO].self, forKey: .relatedTopics) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

// MARK: - 地区图谱 DTO

/// 地区图谱项 DTO
/// 对齐 Android RegionAtlasItemDto
struct RegionAtlasItemDTO: Decodable, Sendable {
    let region: String?
    let displayName: String?
    let directoryItemCount: Int
    let inheritorCount: Int
    let total: Int
    let topCategories: [FacetBucketDTO]
    let topKinds: [FacetBucketDTO]
    let coverImage: MediaAssetDTO?

    enum CodingKeys: String, CodingKey {
        case region, displayName, directoryItemCount, inheritorCount, total
        case topCategories, topKinds, coverImage
    }

    init(region: String?, displayName: String?, directoryItemCount: Int, inheritorCount: Int, total: Int, topCategories: [FacetBucketDTO], topKinds: [FacetBucketDTO], coverImage: MediaAssetDTO?) {
        self.region = region
        self.displayName = displayName
        self.directoryItemCount = directoryItemCount
        self.inheritorCount = inheritorCount
        self.total = total
        self.topCategories = topCategories
        self.topKinds = topKinds
        self.coverImage = coverImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount) ?? 0
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount) ?? 0
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        topCategories = try container.decodeIfPresent([FacetBucketDTO].self, forKey: .topCategories) ?? []
        topKinds = try container.decodeIfPresent([FacetBucketDTO].self, forKey: .topKinds) ?? []
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
    }
}

/// 地区图谱总计 DTO
/// 对齐 Android RegionAtlasTotalsDto
struct RegionAtlasTotalsDTO: Decodable, Sendable {
    let directoryItemCount: Int
    let inheritorCount: Int
    let regionCount: Int

    enum CodingKeys: String, CodingKey {
        case directoryItemCount, inheritorCount, regionCount
    }

    init(directoryItemCount: Int, inheritorCount: Int, regionCount: Int) {
        self.directoryItemCount = directoryItemCount
        self.inheritorCount = inheritorCount
        self.regionCount = regionCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        directoryItemCount = try container.decodeIfPresent(Int.self, forKey: .directoryItemCount) ?? 0
        inheritorCount = try container.decodeIfPresent(Int.self, forKey: .inheritorCount) ?? 0
        regionCount = try container.decodeIfPresent(Int.self, forKey: .regionCount) ?? 0
    }
}

/// 地区图谱 DTO
/// 对齐 Android RegionAtlasDto
struct RegionAtlasDTO: Decodable, Sendable {
    let regions: [RegionAtlasItemDTO]
    let totals: RegionAtlasTotalsDTO?
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case regions, totals, generatedAt
    }

    init(regions: [RegionAtlasItemDTO], totals: RegionAtlasTotalsDTO?, generatedAt: String?) {
        self.regions = regions
        self.totals = totals
        self.generatedAt = generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        regions = try container.decodeIfPresent([RegionAtlasItemDTO].self, forKey: .regions) ?? []
        totals = try container.decodeIfPresent(RegionAtlasTotalsDTO.self, forKey: .totals)
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

// MARK: - 合集 DTO

/// 合集项 DTO
/// 对齐 Android CollectionItemDto
struct CollectionItemDTO: Decodable, Sendable {
    let id: String?
    let type: String?
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let publishedAt: String?
    let publishedYear: Int?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, type, title, summary, category, region
        case publishedAt, publishedYear, coverImage, sourceUrl
    }

    init(id: String?, type: String?, title: String?, summary: String?, category: String?, region: String?, publishedAt: String?, publishedYear: Int?, coverImage: MediaAssetDTO?, sourceUrl: String?) {
        self.id = id
        self.type = type
        self.title = title
        self.summary = summary
        self.category = category
        self.region = region
        self.publishedAt = publishedAt
        self.publishedYear = publishedYear
        self.coverImage = coverImage
        self.sourceUrl = sourceUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        category = try container.decodeIfPresent(String.self, forKey: .category)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        publishedYear = try container.decodeIfPresent(Int.self, forKey: .publishedYear)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}

/// 精选合集 DTO
/// 对齐 Android FeaturedCollectionDto
struct FeaturedCollectionDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let itemCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, itemCount
    }

    init(id: String?, title: String?, subtitle: String?, itemCount: Int) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.itemCount = itemCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        itemCount = try container.decodeIfPresent(Int.self, forKey: .itemCount) ?? 0
    }
}

/// 合集详情 DTO
/// 对齐 Android CollectionDto
struct CollectionDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let type: String?
    let tags: [String]
    let generatedAt: String?
    let items: [CollectionItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, type, tags, generatedAt, items
    }

    init(id: String?, title: String?, subtitle: String?, type: String?, tags: [String], generatedAt: String?, items: [CollectionItemDTO]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.tags = tags
        self.generatedAt = generatedAt
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
        items = try container.decodeIfPresent([CollectionItemDTO].self, forKey: .items) ?? []
    }
}
