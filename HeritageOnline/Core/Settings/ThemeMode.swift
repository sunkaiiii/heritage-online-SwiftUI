import Foundation

/// 主题模式
enum ThemeMode: String, CaseIterable, Identifiable {
    /// 跟随系统
    case system
    /// 浅色模式
    case light
    /// 暗色模式
    case dark

    var id: String { rawValue }

    /// 本地化显示名称
    var displayName: String {
        switch self {
        case .system:
            return String(localized: "settings.theme.system")
        case .light:
            return String(localized: "settings.theme.light")
        case .dark:
            return String(localized: "settings.theme.dark")
        }
    }
}
