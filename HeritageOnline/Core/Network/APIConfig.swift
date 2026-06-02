import Foundation

/// API 配置，管理 baseUrl 和环境设置
struct APIConfig: Sendable {
    /// 当前环境
    enum Environment: String, Sendable {
        case debug
        case release
    }

    /// 默认 base URL
    private static let defaultBaseURL = "https://localhost:5078"

    /// 共享实例
    static let shared = APIConfig()

    /// 当前环境
    let environment: Environment

    /// API 基础 URL
    let baseURL: URL

    /// 是否信任自签名证书（仅 debug 环境可用）
    let trustSelfSigned: Bool

    /// 请求超时时间（秒）
    let timeoutInterval: TimeInterval

    private init() {
        #if DEBUG
        self.environment = .debug
        self.trustSelfSigned = true
        #else
        self.environment = .release
        self.trustSelfSigned = false
        #endif

        // 从环境变量或配置文件读取 baseUrl
        let urlString = ProcessInfo.processInfo.environment["HERITAGE_API_BASE_URL"]
            ?? Self.defaultBaseURL

        // 安全解析 URL，失败时使用默认值
        if let url = URL(string: urlString) {
            self.baseURL = url
        } else if let defaultURL = URL(string: Self.defaultBaseURL) {
            self.baseURL = defaultURL
        } else {
            // 最后的 fallback，不应该发生
            self.baseURL = URL(fileURLWithPath: "/")
        }

        self.timeoutInterval = 30
    }

    /// 构建完整的 API URL
    func url(for path: String, queryItems: [URLQueryItem]? = nil) -> URL? {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            return nil
        }
        components.queryItems = queryItems
        return components.url
    }
}
