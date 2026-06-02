import SwiftUI

/// 设置管理器，管理主题和语言设置
@Observable
final class SettingsManager {
    /// 共享实例
    static let shared = SettingsManager()

    /// 当前主题模式
    var themeMode: ThemeMode {
        didSet {
            UserDefaults.standard.set(themeMode.rawValue, forKey: Keys.themeMode)
        }
    }

    /// 当前语言模式
    var languageMode: LanguageMode {
        didSet {
            UserDefaults.standard.set(languageMode.rawValue, forKey: Keys.languageMode)
        }
    }

    private enum Keys {
        static let themeMode = "settings.themeMode"
        static let languageMode = "settings.languageMode"
    }

    private init() {
        // 读取保存的主题模式
        if let savedTheme = UserDefaults.standard.string(forKey: Keys.themeMode),
           let mode = ThemeMode(rawValue: savedTheme) {
            self.themeMode = mode
        } else {
            self.themeMode = .system
        }

        // 读取保存的语言模式
        if let savedLanguage = UserDefaults.standard.string(forKey: Keys.languageMode),
           let mode = LanguageMode(rawValue: savedLanguage) {
            self.languageMode = mode
        } else {
            self.languageMode = .system
        }
    }

    /// 获取当前应使用的颜色方案
    var colorScheme: ColorScheme? {
        switch themeMode {
        case .system:
            return nil // 跟随系统
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
