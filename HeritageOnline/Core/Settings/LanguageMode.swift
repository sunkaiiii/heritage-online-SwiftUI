import Foundation

/// 语言模式
enum LanguageMode: String, CaseIterable, Identifiable {
    /// 跟随系统
    case system
    /// 简体中文
    case zhHans = "zh-Hans"
    /// 英语
    case en

    var id: String { rawValue }

    /// 本地化显示名称
    var displayName: String {
        switch self {
        case .system:
            return String(localized: "settings.language.system")
        case .zhHans:
            return "简体中文"
        case .en:
            return "English"
        }
    }

    /// 对应的语言代码
    var languageCode: String? {
        switch self {
        case .system:
            return nil
        case .zhHans:
            return "zh-Hans"
        case .en:
            return "en"
        }
    }
}
