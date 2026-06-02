import Foundation

/// Heritage HTTP 客户端配置
/// 对齐 Android KtorHeritageApiClient
final class HeritageHTTPClient: NSObject, URLSessionDelegate, Sendable {
    /// 共享实例
    static let shared = HeritageHTTPClient()

    /// API 配置
    private let config: APIConfig

    /// URL 会话
    private nonisolated(unsafe) var session: URLSession

    /// JSON 解码器
    let decoder: JSONDecoder

    /// 自签名证书信任状态（用于 URLSessionDelegate）
    private let trustsSelfSigned: Bool

    override private init() {
        let config = APIConfig.shared
        self.config = config
        self.trustsSelfSigned = config.trustSelfSigned

        // 配置 URLSession
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = config.timeoutInterval
        sessionConfig.timeoutIntervalForResource = config.timeoutInterval * 2
        sessionConfig.waitsForConnectivity = true

        // 配置 JSON 解码器
        self.decoder = JSONDecoder()

        // 初始创建 URLSession（不带 delegate）
        self.session = URLSession(configuration: sessionConfig)

        super.init()

        // 在 DEBUG 环境下，如果需要信任自签名证书，重新创建带 delegate 的 session
        #if DEBUG
        if config.trustSelfSigned {
            self.session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        }
        #endif
    }

    // MARK: - 请求方法

    /// 发送 GET 请求（字符串路径）
    /// - Parameters:
    ///   - path: API 路径
    ///   - queryItems: 查询参数
    /// - Returns: 解码后的响应
    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        do {
            let url = try buildURL(path: path, queryItems: queryItems)
            let (data, response) = try await session.data(from: url)
            try validateResponse(response, data: data)
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as URLError {
            throw NetworkError.from(error)
        } catch {
            throw NetworkError.underlying(error)
        }
    }

    /// 发送 GET 请求（路径段数组）
    /// - Parameters:
    ///   - segments: 路径段数组，每段会独立编码
    ///   - queryItems: 查询参数
    /// - Returns: 解码后的响应
    func get<T: Decodable>(_ segments: [String], queryItems: [URLQueryItem] = []) async throws -> T {
        do {
            let url = try buildURL(pathSegments: segments, queryItems: queryItems)
            let (data, response) = try await session.data(from: url)
            try validateResponse(response, data: data)
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error)
        } catch let error as URLError {
            throw NetworkError.from(error)
        } catch {
            throw NetworkError.underlying(error)
        }
    }

    /// 发送 GET 请求（无响应体，字符串路径）
    /// - Parameters:
    ///   - path: API 路径
    ///   - queryItems: 查询参数
    func get(_ path: String, queryItems: [URLQueryItem] = []) async throws {
        do {
            let url = try buildURL(path: path, queryItems: queryItems)
            let (data, response) = try await session.data(from: url)
            try validateResponse(response, data: data)
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw NetworkError.from(error)
        } catch {
            throw NetworkError.underlying(error)
        }
    }

    /// 发送 GET 请求（无响应体，路径段数组）
    /// - Parameters:
    ///   - segments: 路径段数组，每段会独立编码
    ///   - queryItems: 查询参数
    func get(_ segments: [String], queryItems: [URLQueryItem] = []) async throws {
        do {
            let url = try buildURL(pathSegments: segments, queryItems: queryItems)
            let (data, response) = try await session.data(from: url)
            try validateResponse(response, data: data)
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw NetworkError.from(error)
        } catch {
            throw NetworkError.underlying(error)
        }
    }

    // MARK: - URL 构建

    /// 构建完整 URL（字符串路径）
    /// - Parameters:
    ///   - path: API 路径
    ///   - queryItems: 查询参数
    /// - Returns: 完整 URL
    func buildURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidBaseURL
        }

        // 拼接路径，使用 percentEncodedPath 避免 URLComponents 二次编码。
        let encodedSegments = path.split(separator: "/").map { Self.pathSegment(String($0)) }
        components.percentEncodedPath = Self.joinedPercentEncodedPath(
            basePath: components.percentEncodedPath,
            encodedSegments: encodedSegments
        )

        // 添加查询参数（过滤空值）
        let validQueryItems = queryItems.filter { $0.value != nil && !$0.value!.isEmpty }
        if !validQueryItems.isEmpty {
            components.queryItems = validQueryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return url
    }

    /// 构建完整 URL（路径段数组）
    /// 每个路径段会独立编码，斜杠会被编码为 %2F
    /// - Parameters:
    ///   - segments: 路径段数组
    ///   - queryItems: 查询参数
    /// - Returns: 完整 URL
    func buildURL(pathSegments segments: [String], queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidBaseURL
        }

        // 每个段独立编码，使用 percentEncodedPath 避免 URLComponents 二次编码。
        let encodedSegments = segments.map { Self.pathSegment($0) }
        components.percentEncodedPath = Self.joinedPercentEncodedPath(
            basePath: components.percentEncodedPath,
            encodedSegments: encodedSegments
        )

        // 添加查询参数（过滤空值）
        let validQueryItems = queryItems.filter { $0.value != nil && !$0.value!.isEmpty }
        if !validQueryItems.isEmpty {
            components.queryItems = validQueryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        return url
    }

    // MARK: - 路径编码

    /// 对路径段进行安全编码
    /// 处理中文、空格、斜杠、特殊符号
    /// - Parameter value: 原始路径段
    /// - Returns: 编码后的路径段
    static func pathSegment(_ value: String) -> String {
        // 使用 URL 编码，保留字母和数字
        let allowed = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "-._~"))
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }

    private static func joinedPercentEncodedPath(basePath: String, encodedSegments: [String]) -> String {
        let suffix = encodedSegments.filter { !$0.isEmpty }.joined(separator: "/")
        guard !suffix.isEmpty else {
            return basePath.isEmpty ? "/" : basePath
        }

        let normalizedBase = basePath == "/" ? "" : basePath.trimmingTrailingSlashes()
        return normalizedBase.isEmpty ? "/" + suffix : normalizedBase + "/" + suffix
    }

    // MARK: - 响应验证

    /// 验证 HTTP 响应
    /// - Parameters:
    ///   - response: URL 响应
    ///   - data: 响应数据
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return // 成功
        case 400:
            let problemDetails = try? decoder.decode(ProblemDetailsDTO.self, from: data)
            throw NetworkError.badRequestWithDetails(problemDetails)
        case 404:
            let problemDetails = try? decoder.decode(ProblemDetailsDTO.self, from: data)
            throw NetworkError.notFoundWithDetails(problemDetails)
        case 500...599:
            let problemDetails = try? decoder.decode(ProblemDetailsDTO.self, from: data)
            throw NetworkError.serverErrorWithDetails(problemDetails)
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - 网络错误类型

/// 网络错误类型
/// 对齐 Android 错误类型
enum NetworkError: Error, LocalizedError {
    case invalidBaseURL
    case invalidURL
    case invalidResponse
    case badRequest
    case badRequestWithDetails(ProblemDetailsDTO?)
    case notFound
    case notFoundWithDetails(ProblemDetailsDTO?)
    case serverError
    case serverErrorWithDetails(ProblemDetailsDTO?)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkUnavailable
    case timeout
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return String(localized: "error.invalidBaseURL")
        case .invalidURL:
            return String(localized: "error.invalidURL")
        case .invalidResponse:
            return String(localized: "error.invalidResponse")
        case .badRequest:
            return String(localized: "error.badRequest")
        case .badRequestWithDetails(let details):
            return details?.detail ?? String(localized: "error.badRequest")
        case .notFound:
            return String(localized: "error.notFound")
        case .notFoundWithDetails(let details):
            return details?.detail ?? String(localized: "error.notFound")
        case .serverError:
            return String(localized: "error.serverError")
        case .serverErrorWithDetails(let details):
            return details?.detail ?? String(localized: "error.serverError")
        case .httpError(let statusCode):
            return String(localized: "error.httpError \(statusCode)")
        case .decodingError:
            return String(localized: "error.decodingError")
        case .networkUnavailable:
            return String(localized: "error.network")
        case .timeout:
            return String(localized: "error.timeout")
        case .underlying(let error):
            return error.localizedDescription
        }
    }

    /// 从 URLError 转换
    static func from(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotConnectToHost,
             .cannotFindHost,
             .dnsLookupFailed:
            return .networkUnavailable
        case .timedOut:
            return .timeout
        case .badServerResponse,
             .cannotParseResponse:
            return .invalidResponse
        default:
            return .underlying(error)
        }
    }

    /// 从 NSError 转换
    static func from(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            return from(urlError)
        }
        return .underlying(error)
    }
}

// MARK: - 查询参数构建器

/// 查询参数构建器
/// 用于构建 API 查询参数
struct QueryBuilder {
    private var items: [URLQueryItem] = []

    /// 添加参数（忽略 nil 和空值）
    /// - Parameters:
    ///   - name: 参数名
    ///   - value: 参数值
    /// - Returns: 自身
    @discardableResult
    mutating func add(_ name: String, value: String?) -> Self {
        if let value, !value.isEmpty {
            items.append(URLQueryItem(name: name, value: value))
        }
        return self
    }

    /// 添加参数（忽略 nil）
    /// - Parameters:
    ///   - name: 参数名
    ///   - value: 参数值
    /// - Returns: 自身
    @discardableResult
    mutating func add(_ name: String, value: Int?) -> Self {
        if let value {
            items.append(URLQueryItem(name: name, value: String(value)))
        }
        return self
    }

    /// 添加参数（忽略 nil）
    /// - Parameters:
    ///   - name: 参数名
    ///   - value: 参数值
    /// - Returns: 自身
    @discardableResult
    mutating func add(_ name: String, value: Bool?) -> Self {
        if let value {
            items.append(URLQueryItem(name: name, value: value ? "true" : "false"))
        }
        return self
    }

    /// 添加数组参数（忽略空数组）
    /// - Parameters:
    ///   - name: 参数名
    ///   - values: 参数值数组
    /// - Returns: 自身
    @discardableResult
    mutating func add(_ name: String, values: [String]) -> Self {
        if !values.isEmpty {
            items.append(URLQueryItem(name: name, value: values.joined(separator: ",")))
        }
        return self
    }

    /// 构建查询参数数组
    /// - Returns: URLQueryItem 数组
    func build() -> [URLQueryItem] {
        items
    }
}

// MARK: - URLSessionDelegate (自签名证书支持)

#if DEBUG
extension HeritageHTTPClient {
    /// 处理服务器证书验证
    /// 仅在 debug 环境下信任自签名证书，且仅限 localhost/127.0.0.1
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // 仅处理服务器信任挑战
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // 仅信任 localhost 和 127.0.0.1（iOS 开发常用地址）
        let host = challenge.protectionSpace.host
        let trustedHosts = ["localhost", "127.0.0.1"]

        guard trustsSelfSigned && trustedHosts.contains(host) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 创建凭证并信任证书
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}
#endif

private extension String {
    func trimmingTrailingSlashes() -> String {
        var value = self
        while value.hasSuffix("/") {
            value.removeLast()
        }
        return value
    }
}
