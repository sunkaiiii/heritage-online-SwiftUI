import Foundation

/// 日期显示格式化工具
/// 将后端日期字符串转换为用户友好的本地化显示格式
enum DateDisplayFormatter {
    /// 格式化日期字符串为用户友好格式
    /// - Parameter value: ISO 8601 或 yyyy-MM-dd 格式的日期字符串
    /// - Returns: 本地化友好日期，如 "2026年4月22日"；解析失败则返回原始字符串
    static func displayDate(from value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }

        // 尝试 ISO 8601
        if let date = ISO8601DateFormatter().date(from: value) {
            return formatLocalized(date)
        }
        // 尝试 yyyy-MM-dd
        if value.count >= 10 {
            let prefix = String(value.prefix(10))
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: prefix) {
                return formatLocalized(date)
            }
        }
        // 解析失败，返回原始字符串
        return value
    }

    /// 使用 DateFormatter 输出本地化日期
    private static func formatLocalized(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
