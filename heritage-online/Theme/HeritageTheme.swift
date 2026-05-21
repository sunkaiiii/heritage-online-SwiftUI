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

// MARK: - Heritage Color Scheme

struct HeritageColors {
    // Light Theme
    static let lightPrimary = Color(hex: "8F372F")
    static let lightOnPrimary = Color.white
    static let lightPrimaryContainer = Color(hex: "FFDAD4")
    static let lightOnPrimaryContainer = Color(hex: "3A0905")
    static let lightSecondary = Color(hex: "6B5852")
    static let lightSecondaryContainer = Color(hex: "EFE2DC")
    static let lightTertiary = Color(hex: "735C23")
    static let lightTertiaryContainer = Color(hex: "FFE1A6")
    static let lightBackground = Color(hex: "FCF8F5")
    static let lightOnBackground = Color(hex: "211A18")
    static let lightSurface = Color(hex: "FCF8F5")
    static let lightOnSurface = Color(hex: "211A18")
    static let lightSurfaceVariant = Color(hex: "EADDD7")
    static let lightOnSurfaceVariant = Color(hex: "51443F")
    static let lightSurfaceContainerLow = Color(hex: "FBF3EF")
    static let lightSurfaceContainer = Color(hex: "F5ECE7")
    static let lightSurfaceContainerHigh = Color(hex: "EFE3DE")
    static let lightOutline = Color(hex: "83736D")
    static let lightOutlineVariant = Color(hex: "D6C2BA")

    // Dark Theme
    static let darkPrimary = Color(hex: "FFB4AA")
    static let darkOnPrimary = Color(hex: "561E19")
    static let darkPrimaryContainer = Color(hex: "733028")
    static let darkOnPrimaryContainer = Color(hex: "FFDAD4")
    static let darkSecondary = Color(hex: "D8C2BA")
    static let darkSecondaryContainer = Color(hex: "51403A")
    static let darkTertiary = Color(hex: "E2C47C")
    static let darkTertiaryContainer = Color(hex: "594419")
    static let darkBackground = Color(hex: "16100E")
    static let darkOnBackground = Color(hex: "EDE0DC")
    static let darkSurface = Color(hex: "16100E")
    static let darkOnSurface = Color(hex: "EDE0DC")
    static let darkSurfaceVariant = Color(hex: "51443F")
    static let darkOnSurfaceVariant = Color(hex: "D6C2BA")
    static let darkSurfaceContainerLow = Color(hex: "241D1A")
    static let darkSurfaceContainer = Color(hex: "2A211E")
    static let darkSurfaceContainerHigh = Color(hex: "362B27")
    static let darkOutline = Color(hex: "9F8D86")
    static let darkOutlineVariant = Color(hex: "5D4C45")
}

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
