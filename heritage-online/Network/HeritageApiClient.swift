import Foundation

// MARK: - API Client Protocol

protocol HeritageApiClientProtocol {
    func getHomeBanners() async throws -> [HomeBannerDto]
    func getArticles(query: ArticleQuery) async throws -> PagedResult<ArticleSummaryDto>
    func getArticle(id: String) async throws -> ArticleDetailDto
    func getArticleBySourceId(_ sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDto
    func getArticleBySourceUrl(_ sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDto
    func getDirectoryItems(query: DirectoryItemQuery) async throws -> PagedResult<DirectoryItemSummaryDto>
    func getDirectoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDto
    func getDirectoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDto
    func getDirectoryItem(id: String) async throws -> DirectoryItemDetailDto
    func getDirectoryItemBySourceId(_ sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDto
    func getInheritors(query: InheritorQuery) async throws -> PagedResult<InheritorSummaryDto>
    func getInheritor(id: String) async throws -> InheritorDetailDto
    func getInheritorBySourceId(_ sourceId: String) async throws -> InheritorDetailDto
}

// MARK: - API Client Implementation

class HeritageApiClient: HeritageApiClientProtocol {
    private let baseUrl: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(config: HeritageApiConfig = HeritageApiConfig()) {
        self.baseUrl = config.baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        let configuration = URLSessionConfiguration.default
        if config.trustSelfSignedCertificates {
            configuration.timeoutIntervalForRequest = 30
        }
        self.session = URLSession(configuration: configuration, delegate: TrustAllCertificatesDelegate(), delegateQueue: nil)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .useDefaultKeys
    }

    // MARK: - Home Banners

    func getHomeBanners() async throws -> [HomeBannerDto] {
        let data = try await get(path: "api/home-banners")
        return try decoder.decode([HomeBannerDto].self, from: data)
    }

    // MARK: - Articles

    func getArticles(query: ArticleQuery) async throws -> PagedResult<ArticleSummaryDto> {
        let data = try await get(path: "api/articles", queryItems: query.toQueryItems())
        return try decoder.decode(PagedResult<ArticleSummaryDto>.self, from: data)
    }

    func getArticle(id: String) async throws -> ArticleDetailDto {
        let data = try await get(path: "api/articles/\(id)")
        return try decoder.decode(ArticleDetailDto.self, from: data)
    }

    func getArticleBySourceId(_ sourceId: String, category: ArticleCategory) async throws -> ArticleDetailDto {
        let data = try await get(path: "api/articles/source/\(sourceId)", queryItems: [
            URLQueryItem(name: "category", value: category.rawValue),
        ])
        return try decoder.decode(ArticleDetailDto.self, from: data)
    }

    func getArticleBySourceUrl(_ sourceUrl: String, category: ArticleCategory) async throws -> ArticleDetailDto {
        let data = try await get(path: "api/articles/source", queryItems: [
            URLQueryItem(name: "category", value: category.rawValue),
            URLQueryItem(name: "sourceUrl", value: sourceUrl),
        ])
        return try decoder.decode(ArticleDetailDto.self, from: data)
    }

    // MARK: - Directory Items

    func getDirectoryItems(query: DirectoryItemQuery) async throws -> PagedResult<DirectoryItemSummaryDto> {
        let data = try await get(path: "api/directory-items", queryItems: query.toQueryItems())
        return try decoder.decode(PagedResult<DirectoryItemSummaryDto>.self, from: data)
    }

    func getDirectoryStatisticsOverview(kind: DirectoryItemKind) async throws -> DirectoryStatisticsOverviewDto {
        let data = try await get(path: "api/directory-items/statistics", queryItems: [
            URLQueryItem(name: "kind", value: kind.rawValue),
        ])
        return try decoder.decode(DirectoryStatisticsOverviewDto.self, from: data)
    }

    func getDirectoryStatisticsBreakdown(kind: DirectoryItemKind, dimension: DirectoryStatisticDimension, limit: Int) async throws -> DirectoryStatisticDimensionDto {
        let data = try await get(path: "api/directory-items/statistics/breakdown", queryItems: [
            URLQueryItem(name: "kind", value: kind.rawValue),
            URLQueryItem(name: "dimension", value: dimension.rawValue),
            URLQueryItem(name: "limit", value: String(limit)),
        ])
        return try decoder.decode(DirectoryStatisticDimensionDto.self, from: data)
    }

    func getDirectoryItem(id: String) async throws -> DirectoryItemDetailDto {
        let data = try await get(path: "api/directory-items/\(id)")
        return try decoder.decode(DirectoryItemDetailDto.self, from: data)
    }

    func getDirectoryItemBySourceId(_ sourceId: String, kind: DirectoryItemKind) async throws -> DirectoryItemDetailDto {
        let data = try await get(path: "api/directory-items/source/\(sourceId)", queryItems: [
            URLQueryItem(name: "kind", value: kind.rawValue),
        ])
        return try decoder.decode(DirectoryItemDetailDto.self, from: data)
    }

    // MARK: - Inheritors

    func getInheritors(query: InheritorQuery) async throws -> PagedResult<InheritorSummaryDto> {
        let data = try await get(path: "api/inheritors", queryItems: query.toQueryItems())
        return try decoder.decode(PagedResult<InheritorSummaryDto>.self, from: data)
    }

    func getInheritor(id: String) async throws -> InheritorDetailDto {
        let data = try await get(path: "api/inheritors/\(id)")
        return try decoder.decode(InheritorDetailDto.self, from: data)
    }

    func getInheritorBySourceId(_ sourceId: String) async throws -> InheritorDetailDto {
        let data = try await get(path: "api/inheritors/source/\(sourceId)")
        return try decoder.decode(InheritorDetailDto.self, from: data)
    }

    // MARK: - HTTP Methods

    private func get(path: String, queryItems: [URLQueryItem]? = nil) async throws -> Data {
        guard var components = URLComponents(string: "\(baseUrl)/\(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))") else {
            throw ApiError.invalidURL
        }
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 404 {
                throw ApiError.notFound
            }
            throw ApiError.serverError(statusCode: httpResponse.statusCode)
        }

        return data
    }
}

// MARK: - Error Types

enum ApiError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case notFound
    case serverError(statusCode: Int)
    case networkUnavailable
    case timeout
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL, .invalidResponse: return String(localized: "error_network_unavailable")
        case .notFound: return String(localized: "content_not_available")
        case .serverError: return String(localized: "error_server_unavailable")
        case .networkUnavailable: return String(localized: "error_network_unavailable")
        case .timeout: return String(localized: "error_timeout")
        case .unknown: return String(localized: "content_load_failed")
        }
    }
}

// MARK: - Shared Trusted URLSession for Images

let heritageTrustedSession: URLSession = {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30
    return URLSession(configuration: config, delegate: TrustAllCertificatesDelegate(), delegateQueue: nil)
}()

// MARK: - Self-Signed Certificate Support

class TrustAllCertificatesDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
