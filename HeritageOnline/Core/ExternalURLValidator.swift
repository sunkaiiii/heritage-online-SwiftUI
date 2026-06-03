import Foundation

/// 外部 URL 验证工具
/// 统一校验 URL 是否为合法的 http/https 链接，防止打开异常 scheme
enum ExternalURLValidator {
    /// 从原始字符串中解析出合法的 http/https URL
    /// - Parameter rawValue: 原始 URL 字符串
    /// - Returns: 合法的 http/https URL，否则返回 nil
    static func httpURL(from rawValue: String?) -> URL? {
        guard
            let rawValue,
            !rawValue.trimmingCharacters(in: .whitespaces).isEmpty,
            let url = URL(string: rawValue),
            let scheme = url.scheme?.lowercased(),
            ["http", "https"].contains(scheme)
        else { return nil }
        return url
    }
}
