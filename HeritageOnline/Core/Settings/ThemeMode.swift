import Foundation
import SwiftUI

/// 主题模式
enum ThemeMode: String, CaseIterable, Identifiable {
    /// 跟随系统
    case system
    /// 浅色模式
    case light
    /// 暗色模式
    case dark

    var id: String { rawValue }

    var localizationKey: LocalizedStringKey {
        switch self {
        case .system:
            return "settings.theme.system"
        case .light:
            return "settings.theme.light"
        case .dark:
            return "settings.theme.dark"
        }
    }
}
