import Foundation

/// Heritage API 客户端默认实现
/// 使用 URLSession 进行网络请求
final class DefaultHeritageAPIClient: HeritageAPIClient {
    private let httpClient: HeritageHTTPClient

    init(httpClient: HeritageHTTPClient = .shared) {
        self.httpClient = httpClient
    }

    // MARK: - 首页

    func getHomeBanners() async throws -> [HomeBannerDTO] {
        try await httpClient.get("api/home-banners")
    }

    func getHomeFeed() async throws -> HomeFeedDTO {
        try await httpClient.get("api/home/feed")
    }

    // MARK: - 文章

    func getArticles(query: ArticleQuery) async throws -> PagedResultDTO<ArticleSummaryDTO> {
        var builder = QueryBuilder()
        builder.add("category", value: query.category.wireName)
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("year", value: query.year)
        builder.add("keywords", value: query.keywords)
        return try await httpClient.get("api/articles", queryItems: builder.build())
    }

    func getArticle(id: String) async throws -> ArticleDetailDTO {
        try await httpClient.get("api/articles/\(id)")
    }

    func getArticleBySourceId(sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        var builder = QueryBuilder()
        builder.add("category", value: category.wireName)
        return try await httpClient.get(
            "api/articles/source/\(sourceId)",
            queryItems: builder.build()
        )
    }

    func getArticleBySourceUrl(sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDTO {
        var builder = QueryBuilder()
        builder.add("category", value: category.wireName)
        builder.add("sourceUrl", value: sourceUrl)
        return try await httpClient.get("api/articles/source", queryItems: builder.build())
    }

    func getArticleContext(id: String) async throws -> DetailContextDTO {
        try await httpClient.get("api/articles/\(id)/context")
    }

    // MARK: - 名录

    func getDirectoryItems(query: DirectoryItemQuery) async throws -> PagedResultDTO<DirectoryItemSummaryDTO> {
        var builder = QueryBuilder()
        builder.add("kind", value: query.kind.wireName)
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("keywords", value: query.keywords)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        builder.add("year", value: query.year)
        builder.add("listType", value: query.listType)
        return try await httpClient.get("api/directory-items", queryItems: builder.build())
    }

    func getDirectoryItem(id: String) async throws -> DirectoryItemDetailDTO {
        try await httpClient.get("api/directory-items/\(id)")
    }

    func getDirectoryItemBySourceId(sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDTO {
        var builder = QueryBuilder()
        builder.add("kind", value: kind.wireName)
        return try await httpClient.get(
            "api/directory-items/source/\(sourceId)",
            queryItems: builder.build()
        )
    }

    func getDirectoryItemContext(id: String) async throws -> DetailContextDTO {
        try await httpClient.get("api/directory-items/\(id)/context")
    }

    // MARK: - 传承人

    func getInheritors(query: InheritorQuery) async throws -> PagedResultDTO<InheritorSummaryDTO> {
        var builder = QueryBuilder()
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("keywords", value: query.keywords)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        builder.add("year", value: query.year)
        builder.add("gender", value: query.gender)
        return try await httpClient.get("api/inheritors", queryItems: builder.build())
    }

    func getInheritor(id: String) async throws -> InheritorDetailDTO {
        try await httpClient.get("api/inheritors/\(id)")
    }

    func getInheritorBySourceId(sourceId: String) async throws -> InheritorDetailDTO {
        try await httpClient.get("api/inheritors/source/\(sourceId)")
    }

    func getInheritorContext(id: String) async throws -> DetailContextDTO {
        try await httpClient.get("api/inheritors/\(id)/context")
    }

    // MARK: - 搜索

    func searchV2(query: SearchV2Query) async throws -> SearchV2ResponseDTO {
        var builder = QueryBuilder()
        builder.add("keywords", value: query.keywords)
        builder.add("types", values: query.types.map { $0.wireName })
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("region", value: query.region)
        builder.add("category", value: query.category)
        builder.add("year", value: query.year)
        builder.add("kind", value: query.kind?.wireName)
        builder.add("hasImage", value: query.hasImage)
        return try await httpClient.get("api/search/v2", queryItems: builder.build())
    }

    func getSearchSuggestions(prefix: String, limit: Int = 10) async throws -> [SearchSuggestionDTO] {
        var builder = QueryBuilder()
        builder.add("prefix", value: prefix)
        builder.add("limit", value: limit)
        return try await httpClient.get("api/search/suggestions", queryItems: builder.build())
    }

    // MARK: - 时间线

    func getTimelineV2(query: TimelineV2Query) async throws -> TimelineV2ResponseDTO {
        var builder = QueryBuilder()
        builder.add("year", value: query.year)
        builder.add("types", values: query.types.map { $0.wireName })
        builder.add("page", value: query.page)
        builder.add("pageSize", value: query.pageSize)
        builder.add("category", value: query.category)
        builder.add("region", value: query.region)
        builder.add("kind", value: query.kind?.wireName)
        builder.add("hasImage", value: query.hasImage)
        return try await httpClient.get("api/timeline/v2", queryItems: builder.build())
    }

    func getTimelineYears() async throws -> [TimelineYearBucketDTO] {
        try await httpClient.get("api/timeline/years")
    }
}
