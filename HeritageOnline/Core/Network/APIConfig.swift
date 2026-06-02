import Foundation

/// API 配置，管理 baseUrl 和环境设置
struct APIConfig: Sendable {
    /// 当前环境
    enum Environment: String, Sendable {
        case debug
        case release
    }

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
        #if targetEnvironment(simulator)
        // iOS 模拟器使用 localhost
        let urlString = ProcessInfo.processInfo.environment["HERITAGE_API_BASE_URL"]
            ?? "https://localhost:5078"
        #else
        // 真机和其他平台使用配置的 URL
        let urlString = ProcessInfo.processInfo.environment["HERITAGE_API_BASE_URL"]
            ?? "https://localhost:5078"
        #endif

        self.baseURL = URL(string: urlString)!
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
