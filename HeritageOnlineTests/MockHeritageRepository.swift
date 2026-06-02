import Foundation
@testable import HeritageOnline

/// Mock Heritage Repository
/// 用于单元测试，可以替换真实实现
final class MockHeritageRepository: HeritageRepository {
    // MARK: - Mock 数据

    var homeBannersResult: Result<[HomeBannerDTO], Error> = .success([])
    var homeFeedResult: Result<HomeFeedDTO, Error> = .success(HomeFeedDTO(banners: nil, articles: nil))
    var articlesResult: Result<PagedResultDTO<ArticleSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, totalCount: 0, hasMore: false)
    )
    var articleResult: Result<ArticleDetailDTO, Error> = .success(
        ArticleDetailDTO(id: "test", title: nil, summary: nil, category: nil, imageUrl: nil, publishedAt: nil, sourceUrl: nil, author: nil, content: nil, contentBlocks: nil)
    )
    var directoryItemsResult: Result<PagedResultDTO<DirectoryItemSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, totalCount: 0, hasMore: false)
    )
    var directoryItemResult: Result<DirectoryItemDetailDTO, Error> = .success(
        DirectoryItemDetailDTO(id: "test", title: nil, summary: nil, kind: nil, category: nil, region: nil, imageUrl: nil, projectCode: nil, batch: nil, publishedYear: nil, content: nil, contentBlocks: nil)
    )
    var inheritorsResult: Result<PagedResultDTO<InheritorSummaryDTO>, Error> = .success(
        PagedResultDTO(items: [], page: 1, pageSize: 20, totalCount: 0, hasMore: false)
    )
    var inheritorResult: Result<InheritorDetailDTO, Error> = .success(
        InheritorDetailDTO(id: "test", name: nil, projectName: nil, gender: nil, ethnicity: nil, category: nil, region: nil, imageUrl: nil, description: nil, contentBlocks: nil)
    )
    var searchV2Result: Result<SearchV2ResponseDTO, Error> = .success(
        SearchV2ResponseDTO(items: [], totalCount: 0, page: 1, pageSize: 20, hasMore: false)
    )
    var searchSuggestionsResult: Result<[SearchSuggestionDTO], Error> = .success([])
    var timelineV2Result: Result<TimelineV2ResponseDTO, Error> = .success(
        TimelineV2ResponseDTO(items: [], page: 1, pageSize: 20, hasMore: false)
    )
    var timelineYearsResult: Result<[TimelineYearBucketDTO], Error> = .success([])
    var articleContextResult: Result<DetailContextDTO, Error> = .success(
        DetailContextDTO(related: nil, recommendations: nil, semanticRecommendations: nil, collections: nil, exploreTopics: nil)
    )
    var directoryItemContextResult: Result<DetailContextDTO, Error> = .success(
        DetailContextDTO(related: nil, recommendations: nil, semanticRecommendations: nil, collections: nil, exploreTopics: nil)
    )
    var inheritorContextResult: Result<DetailContextDTO, Error> = .success(
        DetailContextDTO(related: nil, recommendations: nil, semanticRecommendations: nil, collections: nil, exploreTopics: nil)
    )

    // MARK: - 调用记录

    var homeBannersCallCount = 0
    var articlesCallCount = 0
    var articleCallCount = 0
    var articleBySourceIdCallCount = 0
    var articleBySourceUrlCallCount = 0
    var directoryItemsCallCount = 0
    var directoryItemCallCount = 0
    var directoryItemBySourceIdCallCount = 0
    var inheritorsCallCount = 0
    var inheritorCallCount = 0
    var inheritorBySourceIdCallCount = 0

    // MARK: - Repository 实现

    func homeBanners() async throws -> [HomeBannerDTO] {
        homeBannersCallCount += 1
        return try homeBannersResult.get()
    }

    func homeFeed() async throws -> HomeFeedDTO {
        try homeFeedResult.get()
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

    func directoryItemContext(id: String) async throws -> DetailContextDTO {
        try directoryItemContextResult.get()
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

    func inheritorContext(id: String) async throws -> DetailContextDTO {
        try inheritorContextResult.get()
    }

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        try searchV2Result.get()
    }

    func searchSuggestions(prefix: String, limit: Int) async throws -> [SearchSuggestionDTO] {
        try searchSuggestionsResult.get()
    }

    func timelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        try timelineV2Result.get()
    }

    func timelineYears() async throws -> [TimelineYearBucketDTO] {
        try timelineYearsResult.get()
    }
}
