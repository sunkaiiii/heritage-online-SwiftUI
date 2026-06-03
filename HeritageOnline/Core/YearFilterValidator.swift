import Foundation

/// 年份筛选校验工具
/// 统一处理年份输入的校验和解析，避免各 ViewModel 重复实现
enum YearFilterValidator {
    /// 校验年份是否合法（4 位数字，1000-2999）
    static func isValidYear(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard trimmed.count == 4, let year = Int(trimmed) else { return false }
        return year >= 1000 && year <= 2999
    }

    /// 解析年份字符串为 Int，非法输入返回 nil
    /// 空字符串返回 nil，非空必须是合法 4 位数字
    static func parseInt(_ text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        guard let year = Int(trimmed), isValidYear(trimmed) else { return nil }
        return year
    }
}
