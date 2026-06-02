import Foundation

/// 文章详情查找参数
/// 完全对齐 Android ArticleDetailLookup
struct ArticleDetailLookup: Sendable {
    let articleId: String?
    let sourceId: String?
    let sourceUrl: String?
    let category: ArticleCategory

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news
    ) {
        self.articleId = articleId
        self.sourceId = sourceId
        self.sourceUrl = sourceUrl
        self.category = category
    }
}

/// 名录详情查找参数
/// 完全对齐 Android DirectoryDetailLookup
struct DirectoryDetailLookup: Sendable {
    let itemId: String?
    let sourceId: String?
    let kind: DirectoryItemKind

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject
    ) {
        self.itemId = itemId
        self.sourceId = sourceId
        self.kind = kind
    }
}

/// 传承人详情查找参数
/// 完全对齐 Android InheritorDetailLookup
struct InheritorDetailLookup: Sendable {
    let inheritorId: String?
    let sourceId: String?

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil
    ) {
        self.inheritorId = inheritorId
        self.sourceId = sourceId
    }
}

/// Heritage Repository 接口
/// 完全对齐 Android HeritageRepository
/// UI 只依赖 Repository，不直接依赖 API client
protocol HeritageRepository: Sendable {
    // MARK: - 首页

    /// 获取首页 Banner
    func homeBanners() async throws -> [HomeBannerDTO]

    /// 获取首页 Feed
    func homeFeed() async throws -> HomeFeedDTO

    // MARK: - 文章

    /// 获取文章列表
    func articles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO>

    /// 获取文章详情
    func article(id: String) async throws -> ArticleDetailDTO

    /// 通过 sourceId 获取文章详情
    func articleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO

    /// 通过 sourceUrl 获取文章详情
    func articleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO

    /// 获取文章 Context
    func articleContext(id: String) async throws -> DetailContextDTO

    // MARK: - 名录

    /// 获取名录列表
    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO>

    /// 获取名录详情
    func directoryItem(id: String) async throws -> DirectoryItemDetailDTO

    /// 通过 sourceId 获取名录详情
    func directoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO

    /// 获取名录 Context
    func directoryItemContext(id: String) async throws -> DetailContextDTO

    /// 获取名录统计总览
    func directoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDTO

    /// 获取名录统计 breakdown
    func directoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDTO

    // MARK: - 传承人

    /// 获取传承人列表
    func inheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO>

    /// 获取传承人详情
    func inheritor(id: String) async throws -> InheritorDetailDTO

    /// 通过 sourceId 获取传承人详情
    func inheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO

    /// 获取传承人 Context
    func inheritorContext(id: String) async throws -> DetailContextDTO

    // MARK: - 搜索

    /// 搜索 v2
    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO

    /// 获取搜索建议
    func searchSuggestions(prefix: String, limit: Int) async throws -> [SearchSuggestionDTO]

    // MARK: - 时间线

    /// 获取时间线
    func timelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO

    /// 获取年份聚合
    func timelineYears() async throws -> [TimelineYearBucketDTO]

    // MARK: - Lookup（详情查找）

    /// 根据 lookup 参数获取文章详情
    /// 优先级：articleId -> sourceId -> sourceUrl
    func article(lookup: ArticleDetailLookup) async throws -> ArticleDetailDTO

    /// 根据 lookup 参数获取名录详情
    /// 优先级：itemId -> sourceId
    func directoryItem(lookup: DirectoryDetailLookup) async throws -> DirectoryItemDetailDTO

    /// 根据 lookup 参数获取传承人详情
    /// 优先级：inheritorId -> sourceId
    func inheritor(lookup: InheritorDetailLookup) async throws -> InheritorDetailDTO
}
