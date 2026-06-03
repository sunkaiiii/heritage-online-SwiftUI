import Foundation
@testable import HeritageOnline

/// Mock Heritage Repository
/// 用于单元测试，可以替换真实实现
final class MockHeritageRepository: HeritageRepository, @unchecked Sendable {
    // MARK: - Mock 数据

    var homeBannersResult: Result<[HomeBannerDTO], Error> = .success([])
    var homeFeedResult: Result<HomeFeedDTO, Error> = .success(HomeFeedDTO(
        banners: [],
        latestNews: [],
        latestSpecialTopics: [],
        latestForumArticles: [],
        featuredDirectoryItems: [],
        featuredInheritors: [],
        summary: nil
    ))
    var articlesResult: Result<PagedResultDTO<ArticleSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
    )
    var articleResult: Result<ArticleDetailDTO, Error> = .success(ArticleDetailDTO(
        id: "test",
        category: nil,
        title: nil,
        summary: nil,
        publishedAt: nil,
        coverImage: nil,
        sourceUrl: nil,
        sourceName: nil,
        author: nil,
        editor: nil,
        contentBlocks: [],
        relatedArticles: []
    ))
    var directoryItemsResult: Result<PagedResultDTO<DirectoryItemSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
    )
    var directoryItemResult: Result<DirectoryItemDetailDTO, Error> = .success(DirectoryItemDetailDTO(
        id: "test",
        kind: nil,
        title: nil,
        summary: nil,
        category: nil,
        region: nil,
        projectCode: nil,
        batch: nil,
        publishedYear: nil,
        listType: nil,
        nominationType: nil,
        protectionUnit: nil,
        coverImage: nil,
        sourceUrl: nil,
        gallery: [],
        contentBlocks: [],
        relatedProjects: [],
        relatedInheritors: [],
        relatedDocuments: []
    ))
    var inheritorsResult: Result<PagedResultDTO<InheritorSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, total: 0, hasMore: false)
    )
    var inheritorResult: Result<InheritorDetailDTO, Error> = .success(InheritorDetailDTO(
        id: "test",
        name: nil,
        gender: nil,
        birthDateText: nil,
        ethnicity: nil,
        category: nil,
        projectCode: nil,
        projectName: nil,
        region: nil,
        batch: nil,
        description: nil,
        coverImage: nil,
        sourceUrl: nil,
        contentBlocks: [],
        relatedProjects: [],
        relatedInheritors: []
    ))
    var searchV2Result: Result<SearchV2ResponseDTO, Error> = .success(
        SearchV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil, query: nil)
    )
    var searchSuggestionsResult: Result<[SearchSuggestionDTO], Error> = .success([])
    var timelineV2Result: Result<TimelineV2ResponseDTO, Error> = .success(
        TimelineV2ResponseDTO(items: [], total: 0, page: 1, pageSize: 20, hasMore: false, facets: nil)
    )
    var timelineYearsResult: Result<[TimelineYearBucketDTO], Error> = .success([])
    var articleContextResult: Result<DetailContextDTO, Error> = .success(DetailContextDTO(
        related: [],
        recommendations: [],
        semanticRecommendations: [],
        collections: [],
        exploreTopics: [],
        graph: []
    ))
    var directoryItemContextResult: Result<DetailContextDTO, Error> = .success(DetailContextDTO(
        related: [],
        recommendations: [],
        semanticRecommendations: [],
        collections: [],
        exploreTopics: [],
        graph: []
    ))
    var inheritorContextResult: Result<DetailContextDTO, Error> = .success(DetailContextDTO(
        related: [],
        recommendations: [],
        semanticRecommendations: [],
        collections: [],
        exploreTopics: [],
        graph: []
    ))
    var directoryStatisticsOverviewResult: Result<DirectoryStatisticsOverviewDTO, Error> = .success(
        DirectoryStatisticsOverviewDTO(kind: nil, total: 0, generatedAt: nil, dimensions: [])
    )
    var directoryStatisticsBreakdownResult: Result<DirectoryStatisticDimensionDTO, Error> = .success(
        DirectoryStatisticDimensionDTO(dimension: nil, items: [])
    )

    // MARK: - 调用记录

    var homeBannersCallCount = 0
    var homeFeedCallCount = 0
    var articlesCallCount = 0
    var articleCallCount = 0
    var articleBySourceIdCallCount = 0
    var articleBySourceUrlCallCount = 0
    var articleLookupCallCount = 0
    var directoryItemsCallCount = 0
    var directoryItemCallCount = 0
    var directoryItemBySourceIdCallCount = 0
    var directoryItemLookupCallCount = 0
    var inheritorsCallCount = 0
    var inheritorCallCount = 0
    var inheritorBySourceIdCallCount = 0
    var inheritorLookupCallCount = 0
    var searchV2CallCount = 0
    var timelineV2CallCount = 0
    var directoryStatisticsOverviewCallCount = 0
    var directoryStatisticsBreakdownCallCount = 0

    // MARK: - 参数记录

    var lastDirectoryStatisticsOverviewKind: DirectoryItemKind?
    var lastDirectoryStatisticsBreakdownKind: DirectoryItemKind?
    var lastDirectoryStatisticsBreakdownDimension: DirectoryStatisticDimension?
    var lastDirectoryStatisticsBreakdownLimit: Int?

    // MARK: - Lookup 参数记录

    var lastArticleLookup: ArticleDetailLookup?
    var lastDirectoryLookup: DirectoryDetailLookup?
    var lastInheritorLookup: InheritorDetailLookup?

    // MARK: - Repository 实现

    func homeBanners() async throws -> [HomeBannerDTO] {
        homeBannersCallCount += 1
        return try homeBannersResult.get()
    }

    func homeFeed() async throws -> HomeFeedDTO {
        homeFeedCallCount += 1
        return try homeFeedResult.get()
    }

    func articles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO> {
        articlesCallCount += 1
        return try articlesResult.get()
    }

    func article(id: String) async throws -> ArticleDetailDTO {
        articleCallCount += 1
        return try articleResult.get()
    }

    func articleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        articleBySourceIdCallCount += 1
        return try articleResult.get()
    }

    func articleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        articleBySourceUrlCallCount += 1
        return try articleResult.get()
    }

    func article(lookup: ArticleDetailLookup) async throws -> ArticleDetailDTO {
        articleLookupCallCount += 1
        lastArticleLookup = lookup
        // 模拟优先级逻辑
        if let articleId = lookup.articleId, !articleId.isEmpty {
            return try await article(id: articleId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return try await articleBySourceId(sourceId: sourceId, category: lookup.category)
        } else if let sourceUrl = lookup.sourceUrl, !sourceUrl.isEmpty {
            return try await articleBySourceUrl(sourceUrl: sourceUrl, category: lookup.category)
        } else {
            throw NetworkError.badRequest
        }
    }

    func articleContext(id: String) async throws -> DetailContextDTO {
        try articleContextResult.get()
    }

    func directoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO> {
        directoryItemsCallCount += 1
        return try directoryItemsResult.get()
    }

    func directoryItem(id: String) async throws -> DirectoryItemDetailDTO {
        directoryItemCallCount += 1
        return try directoryItemResult.get()
    }

    func directoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO {
        directoryItemBySourceIdCallCount += 1
        return try directoryItemResult.get()
    }

    func directoryItem(lookup: DirectoryDetailLookup) async throws -> DirectoryItemDetailDTO {
        directoryItemLookupCallCount += 1
        lastDirectoryLookup = lookup
        // 模拟优先级逻辑
        if let itemId = lookup.itemId, !itemId.isEmpty {
            return try await directoryItem(id: itemId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return try await directoryItemBySourceId(sourceId: sourceId, kind: lookup.kind)
        } else {
            throw NetworkError.badRequest
        }
    }

    func directoryItemContext(id: String) async throws -> DetailContextDTO {
        try directoryItemContextResult.get()
    }

    func directoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDTO {
        directoryStatisticsOverviewCallCount += 1
        lastDirectoryStatisticsOverviewKind = kind
        return try directoryStatisticsOverviewResult.get()
    }

    func directoryStatisticsBreakdown(
        kind: DirectoryItemKind,
        dimension: DirectoryStatisticDimension,
        limit: Int
    ) async throws -> DirectoryStatisticDimensionDTO {
        directoryStatisticsBreakdownCallCount += 1
        lastDirectoryStatisticsBreakdownKind = kind
        lastDirectoryStatisticsBreakdownDimension = dimension
        lastDirectoryStatisticsBreakdownLimit = limit
        return try directoryStatisticsBreakdownResult.get()
    }

    func inheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO> {
        inheritorsCallCount += 1
        return try inheritorsResult.get()
    }

    func inheritor(id: String) async throws -> InheritorDetailDTO {
        inheritorCallCount += 1
        return try inheritorResult.get()
    }

    func inheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO {
        inheritorBySourceIdCallCount += 1
        return try inheritorResult.get()
    }

    func inheritor(lookup: InheritorDetailLookup) async throws -> InheritorDetailDTO {
        inheritorLookupCallCount += 1
        lastInheritorLookup = lookup
        // 模拟优先级逻辑
        if let inheritorId = lookup.inheritorId, !inheritorId.isEmpty {
            return try await inheritor(id: inheritorId)
        } else if let sourceId = lookup.sourceId, !sourceId.isEmpty {
            return try await inheritorBySourceId(sourceId: sourceId)
        } else {
            throw NetworkError.badRequest
        }
    }

    func inheritorContext(id: String) async throws -> DetailContextDTO {
        try inheritorContextResult.get()
    }

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        searchV2CallCount += 1
        return try searchV2Result.get()
    }

    func searchSuggestions(prefix: String, limit: Int) async throws -> [SearchSuggestionDTO] {
        try searchSuggestionsResult.get()
    }

    func timelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        timelineV2CallCount += 1
        return try timelineV2Result.get()
    }

    func timelineYears() async throws -> [TimelineYearBucketDTO] {
        try timelineYearsResult.get()
    }
}
