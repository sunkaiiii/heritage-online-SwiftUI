import Foundation

/// Heritage HTTP 客户端配置
/// 完全对齐 Android KtorHeritageApiClient
final class HeritageHTTPClient: Sendable {
    /// 共享实例
    static let shared = HeritageHTTPClient()

    /// API 配置
    private let config: APIConfig

    /// URL 会话
    private let session: URLSession

    /// JSON 解码器
    let decoder: JSONDecoder

    private init() {
        self.config = APIConfig.shared

        // 配置 URLSession
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = config.timeoutInterval
        sessionConfig.timeoutIntervalForResource = config.timeoutInterval * 2
        sessionConfig.waitsForConnectivity = true

        #if DEBUG
        // Debug 环境信任自签名证书
        if config.trustSelfSigned {
            // 注意：这需要在 Info.plist 中配置 NSAllowsLocalNetworking = true
            // 以及在 URLSessionDelegate 中处理证书验证
        }
        #endif

        self.session = URLSession(configuration: sessionConfig)

        // 配置 JSON 解码器
        self.decoder = JSONDecoder()
        // 允许未知字段，避免后端加字段导致客户端崩溃
    }

    // MARK: - 请求方法

    /// 发送 GET 请求
    /// - Parameters:
    ///   - path: API 路径
    ///   - queryItems: 查询参数
    /// - Returns: 解码后的响应
    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        let url = try buildURL(path: path, queryItems: queryItems)
        let (data, response) = try await session.data(from: url)
        try validateResponse(response, data: data)
        return try decoder.decode(T.self, from: data)
    }

    /// 发送 GET 请求（无响应体）
    /// - Parameters:
    ///   - path: API 路径
    ///   - queryItems: 查询参数
    func get(_ path: String, queryItems: [URLQueryItem] = []) async throws {
        let url = try buildURL(path: path, queryItems: queryItems)
        let (data, response) = try await session.data(from: url)
        try validateResponse(response, data: data)
    }

    // MARK: - URL 构建

    /// 构建完整 URL
    /// - Parameters:
    ///   - path: API 路径
    ///   - queryItems: 查询参数
    /// - Returns: 完整 URL
    func buildURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(url: config.baseURL, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidBaseURL
        }

        // 拼接路径，确保路径编码安全
        let encodedPath = path.split(separator: "/").map { Self.pathSegment(String($0)) }.joined(separator: "/")
        components.path = components.path.hasSuffix("/")
            ? components.path + encodedPath
            : components.path + "/" + encodedPath

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
            throw NetworkError.badRequest
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
}

// MARK: - 网络错误类型

/// 网络错误类型
/// 完全对齐 Android 错误类型
enum NetworkError: Error, LocalizedError {
    case invalidBaseURL
    case invalidURL
    case invalidResponse
    case badRequest
    case notFound
    case serverError
    case httpError(statusCode: Int)
    case decodingError(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "无效的 API 基础 URL"
        case .invalidURL:
            return "无效的请求 URL"
        case .invalidResponse:
            return "无效的服务器响应"
        case .badRequest:
            return "请求参数错误"
        case .notFound:
            return "资源不存在"
        case .serverError:
            return "服务器错误"
        case .httpError(let statusCode):
            return "HTTP 错误: \(statusCode)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        }
    }

    /// 从 NSError 转换
    static func from(_ error: Error) -> NetworkError {
        let nsError = error as NSError

        switch nsError.domain {
        case NSURLErrorDomain:
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorCannotConnectToHost:
                return .underlying(error)
            case NSURLErrorTimedOut:
                return .underlying(error)
            default:
                return .underlying(error)
            }
        default:
            return .underlying(error)
        }
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
