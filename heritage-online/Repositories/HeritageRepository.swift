import Foundation

// MARK: - Repository Protocol

protocol HeritageRepositoryProtocol {
    func homeBanners() async throws -> [HomeBannerDto]
    func articles(query: ArticleQuery) async throws -> PagedResult<ArticleSummaryDto>
    func article(id: String) async throws -> ArticleDetailDto
    func articleBySourceId(_ sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDto
    func articleBySourceUrl(_ sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDto
    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResult<DirectoryItemSummaryDto>
    func directoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDto
    func directoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDto
    func directoryItem(id: String) async throws -> DirectoryItemDetailDto
    func directoryItemBySourceId(_ sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDto
    func inheritors(query: InheritorQuery) async throws -> PagedResult<InheritorSummaryDto>
    func inheritor(id: String) async throws -> InheritorDetailDto
    func inheritorBySourceId(_ sourceId: String) async throws -> InheritorDetailDto
}

// MARK: - Repository Implementation

class HeritageRepository: HeritageRepositoryProtocol {
    private let api: HeritageApiClientProtocol
    private let cache = NSCache<NSString, AnyObject>()

    init(api: HeritageApiClientProtocol = HeritageApiClient()) {
        self.api = api
    }

    func homeBanners() async throws -> [HomeBannerDto] {
        let banners = try await api.getHomeBanners()
        return banners.sorted(by: { $0.sortOrder < $1.sortOrder })
    }

    func articles(query: ArticleQuery) async throws -> PagedResult<ArticleSummaryDto> {
        try await api.getArticles(query: query)
    }

    func article(id: String) async throws -> ArticleDetailDto {
        try await api.getArticle(id: id)
    }

    func articleBySourceId(_ sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDto {
        try await api.getArticleBySourceId(sourceId, category: category)
    }

    func articleBySourceUrl(_ sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDto {
        try await api.getArticleBySourceUrl(sourceUrl, category: category)
    }

    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResult<DirectoryItemSummaryDto> {
        try await api.getDirectoryItems(query: query)
    }

    func directoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDto {
        try await api.getDirectoryStatisticsOverview(kind: kind)
    }

    func directoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDto {
        try await api.getDirectoryStatisticsBreakdown(kind: kind, dimension: dimension, limit: limit)
    }

    func directoryItem(id: String) async throws -> DirectoryItemDetailDto {
        try await api.getDirectoryItem(id: id)
    }

    func directoryItemBySourceId(_ sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDto {
        try await api.getDirectoryItemBySourceId(sourceId, kind: kind)
    }

    func inheritors(query: InheritorQuery) async throws -> PagedResult<InheritorSummaryDto> {
        try await api.getInheritors(query: query)
    }

    func inheritor(id: String) async throws -> InheritorDetailDto {
        try await api.getInheritor(id: id)
    }

    func inheritorBySourceId(_ sourceId: String) async throws -> InheritorDetailDto {
        try await api.getInheritorBySourceId(sourceId)
    }
}
