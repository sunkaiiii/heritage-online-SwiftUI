import Foundation
import SwiftUI

/// 语言模式
enum LanguageMode: String, CaseIterable, Identifiable {
    /// 跟随系统
    case system
    /// 简体中文
    case zhHans = "zh-Hans"
    /// 英语
    case en

    var id: String { rawValue }

    var localizationKey: LocalizedStringKey {
        switch self {
        case .system:
            return "settings.language.system"
        case .zhHans:
            return "settings.language.zhHans"
        case .en:
            return "settings.language.en"
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
