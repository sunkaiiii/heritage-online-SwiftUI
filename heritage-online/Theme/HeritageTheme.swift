import SwiftUI

// MARK: - App Theme Mode

enum AppThemeMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var label: String {
        switch self {
        case .system: return String(localized: "theme_system")
        case .light: return String(localized: "theme_light")
        case .dark: return String(localized: "theme_dark")
        }
    }
}

// MARK: - App Language Mode

enum AppLanguageMode: String, CaseIterable {
    case system = "system"
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var label: String {
        switch self {
        case .system: return String(localized: "language_system")
        case .simplifiedChinese: return String(localized: "language_chinese")
        case .english: return String(localized: "language_english")
        }
    }
}

// MARK: - Theme Manager

@MainActor
@Observable
class ThemeManager {
    var mode: AppThemeMode = .system
    var isDark: Bool = false

    func update(mode: AppThemeMode, systemIsDark: Bool) {
        self.mode = mode
        self.isDark = switch mode {
        case .system: systemIsDark
        case .light: false
        case .dark: true
        }
    }

    var background: Color { isDark ? Color(hex: "16100E") : Color(hex: "FCF8F5") }
    var surfaceVariant: Color { isDark ? Color(hex: "51443F") : Color(hex: "EADDD7") }
    var surfaceContainerLow: Color { isDark ? Color(hex: "241D1A") : Color(hex: "FBF3EF") }
    var surfaceContainer: Color { isDark ? Color(hex: "2A211E") : Color(hex: "F5ECE7") }
    var surfaceContainerHigh: Color { isDark ? Color(hex: "362B27") : Color(hex: "EFE3DE") }
    var onSurfaceVariant: Color { isDark ? Color(hex: "D6C2BA") : Color(hex: "51443F") }
    var outline: Color { isDark ? Color(hex: "9F8D86") : Color(hex: "83736D") }
    var outlineVariant: Color { isDark ? Color(hex: "5D4C45") : Color(hex: "D6C2BA") }
    var primary: Color { isDark ? Color(hex: "FFB4AA") : Color(hex: "8F372F") }
    var onPrimary: Color { isDark ? Color(hex: "561E19") : Color.white }
    var primaryContainer: Color { isDark ? Color(hex: "733028") : Color(hex: "FFDAD4") }
    var onPrimaryContainer: Color { isDark ? Color(hex: "FFDAD4") : Color(hex: "3A0905") }
    var onBackground: Color { isDark ? Color(hex: "EDE0DC") : Color(hex: "211A18") }
    var onSurface: Color { isDark ? Color(hex: "EDE0DC") : Color(hex: "211A18") }
}

// MARK: - Color Hex Helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
