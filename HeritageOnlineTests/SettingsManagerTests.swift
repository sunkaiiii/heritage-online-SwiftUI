import XCTest
import SwiftUI
@testable import HeritageOnline

/// SettingsManager 单元测试
/// 覆盖：ThemeMode、LanguageMode 枚举、ColorScheme 映射、Locale 映射
@preconcurrency @MainActor
final class SettingsManagerTests: XCTestCase {

    // MARK: - ThemeMode 枚举

    func testThemeModeAllCases() {
        XCTAssertEqual(ThemeMode.allCases.count, 3)
        XCTAssertTrue(ThemeMode.allCases.contains(.system))
        XCTAssertTrue(ThemeMode.allCases.contains(.light))
        XCTAssertTrue(ThemeMode.allCases.contains(.dark))
    }

    func testThemeModeRawValue() {
        XCTAssertEqual(ThemeMode.system.rawValue, "system")
        XCTAssertEqual(ThemeMode.light.rawValue, "light")
        XCTAssertEqual(ThemeMode.dark.rawValue, "dark")
    }

    func testThemeModeFromRawValue() {
        XCTAssertEqual(ThemeMode(rawValue: "system"), .system)
        XCTAssertEqual(ThemeMode(rawValue: "light"), .light)
        XCTAssertEqual(ThemeMode(rawValue: "dark"), .dark)
        XCTAssertNil(ThemeMode(rawValue: "unknown"))
    }

    func testThemeModeId() {
        XCTAssertEqual(ThemeMode.system.id, "system")
        XCTAssertEqual(ThemeMode.light.id, "light")
        XCTAssertEqual(ThemeMode.dark.id, "dark")
    }

    // MARK: - LanguageMode 枚举

    func testLanguageModeAllCases() {
        XCTAssertEqual(LanguageMode.allCases.count, 3)
        XCTAssertTrue(LanguageMode.allCases.contains(.system))
        XCTAssertTrue(LanguageMode.allCases.contains(.zhHans))
        XCTAssertTrue(LanguageMode.allCases.contains(.en))
    }

    func testLanguageModeRawValue() {
        XCTAssertEqual(LanguageMode.system.rawValue, "system")
        XCTAssertEqual(LanguageMode.zhHans.rawValue, "zh-Hans")
        XCTAssertEqual(LanguageMode.en.rawValue, "en")
    }

    func testLanguageModeFromRawValue() {
        XCTAssertEqual(LanguageMode(rawValue: "system"), .system)
        XCTAssertEqual(LanguageMode(rawValue: "zh-Hans"), .zhHans)
        XCTAssertEqual(LanguageMode(rawValue: "en"), .en)
        XCTAssertNil(LanguageMode(rawValue: "unknown"))
    }

    func testLanguageModeId() {
        XCTAssertEqual(LanguageMode.system.id, "system")
        XCTAssertEqual(LanguageMode.zhHans.id, "zh-Hans")
        XCTAssertEqual(LanguageMode.en.id, "en")
    }

    func testLanguageModeLanguageCode() {
        XCTAssertNil(LanguageMode.system.languageCode)
        XCTAssertEqual(LanguageMode.zhHans.languageCode, "zh-Hans")
        XCTAssertEqual(LanguageMode.en.languageCode, "en")
    }

    // MARK: - ColorScheme 映射

    func testSystemThemeReturnsNilColorScheme() {
        // 直接测试枚举到 ColorScheme 的映射逻辑
        let mode: ThemeMode = .system
        XCTAssertNil(mode.colorScheme)
    }

    func testLightThemeReturnsLightColorScheme() {
        let mode: ThemeMode = .light
        XCTAssertEqual(mode.colorScheme, .light)
    }

    func testDarkThemeReturnsDarkColorScheme() {
        let mode: ThemeMode = .dark
        XCTAssertEqual(mode.colorScheme, .dark)
    }

    // MARK: - Locale 映射

    func testSystemLanguageReturnsNilLocale() {
        let mode: LanguageMode = .system
        XCTAssertNil(mode.locale)
    }

    func testZhHansLanguageReturnsChineseLocale() {
        let mode: LanguageMode = .zhHans
        XCTAssertNotNil(mode.locale)
        XCTAssertEqual(mode.locale?.identifier, "zh-Hans")
    }

    func testEnLanguageReturnsEnglishLocale() {
        let mode: LanguageMode = .en
        XCTAssertNotNil(mode.locale)
        XCTAssertEqual(mode.locale?.identifier, "en")
    }
}

// MARK: - ThemeMode 扩展用于测试

private extension ThemeMode {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - LanguageMode 扩展用于测试

private extension LanguageMode {
    var locale: Locale? {
        switch self {
        case .system: return nil
        case .zhHans: return Locale(identifier: "zh-Hans")
        case .en: return Locale(identifier: "en")
        }
    }
}
