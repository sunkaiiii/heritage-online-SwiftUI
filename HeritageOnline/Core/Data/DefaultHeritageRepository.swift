import Foundation

/// Heritage Repository 默认实现
/// 完全对齐 Android DefaultHeritageRepository
/// 当前阶段不做本地缓存，直接委托给 API client
final class DefaultHeritageRepository: HeritageRepository {
    private let apiClient: HeritageAPIClient

    init(apiClient: HeritageAPIClient = KtorHeritageAPIClient()) {
        self.apiClient = apiClient
    }

    // MARK: - 首页

    func homeBanners() async throws -> [HomeBannerDTO] {
        try await apiClient.getHomeBanners()
    }

    func homeFeed() async throws -> HomeFeedDTO {
        try await apiClient.getHomeFeed()
    }

    // MARK: - 文章

    func articles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO> {
        try await apiClient.getArticles(query: query)
    }

    func article(id: String) async throws -> ArticleDetailDTO {
        try await apiClient.getArticle(id: id)
    }

    func articleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        try await apiClient.getArticleBySourceId(sourceId: sourceId, category: category)
    }

    func articleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        try await apiClient.getArticleBySourceUrl(sourceUrl: sourceUrl, category: category)
    }

    func articleContext(id: String) async throws -> DetailContextDTO {
        try await apiClient.getArticleContext(id: id)
    }

    // MARK: - 名录

    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO> {
        try await apiClient.getDirectoryItems(query: query)
    }

    func directoryItem(id: String) async throws -> DirectoryItemDetailDTO {
        try await apiClient.getDirectoryItem(id: id)
    }

    func directoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO {
        try await apiClient.getDirectoryItemBySourceId(sourceId: sourceId, kind: kind)
    }

    func directoryItemContext(id: String) async throws -> DetailContextDTO {
        try await apiClient.getDirectoryItemContext(id: id)
    }

    // MARK: - 传承人

    func inheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO> {
        try await apiClient.getInheritors(query: query)
    }

    func inheritor(id: String) async throws -> InheritorDetailDTO {
        try await apiClient.getInheritor(id: id)
    }

    func inheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO {
        try await apiClient.getInheritorBySourceId(sourceId: sourceId)
    }

    func inheritorContext(id: String) async throws -> DetailContextDTO {
        try await apiClient.getInheritorContext(id: id)
    }

    // MARK: - 搜索

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        try await apiClient.searchV2(query: query)
    }

    func searchSuggestions(prefix: String, limit: Int = 10) async throws -> [SearchSuggestionDTO] {
        try await apiClient.getSearchSuggestions(prefix: prefix, limit: limit)
    }

    // MARK: - 时间线

    func timelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        try await apiClient.getTimelineV2(query: query)
    }

    func timelineYears() async throws -> [TimelineYearBucketDTO] {
        try await apiClient.getTimelineYears()
    }
}
