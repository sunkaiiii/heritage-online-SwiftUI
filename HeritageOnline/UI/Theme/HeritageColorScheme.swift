import SwiftUI

/// Heritage 应用颜色方案
/// 完全对齐 Android Material 3 色彩系统
struct HeritageColorScheme {
    // MARK: - Primary
    let primary: Color
    let onPrimary: Color
    let primaryContainer: Color
    let onPrimaryContainer: Color

    // MARK: - Secondary
    let secondary: Color
    let onSecondary: Color
    let secondaryContainer: Color
    let onSecondaryContainer: Color

    // MARK: - Tertiary
    let tertiary: Color
    let onTertiary: Color
    let tertiaryContainer: Color
    let onTertiaryContainer: Color

    // MARK: - Background & Surface
    let background: Color
    let onBackground: Color
    let surface: Color
    let onSurface: Color
    let surfaceVariant: Color
    let onSurfaceVariant: Color

    // MARK: - Surface Container
    let surfaceContainerLowest: Color
    let surfaceContainerLow: Color
    let surfaceContainer: Color
    let surfaceContainerHigh: Color
    let surfaceContainerHighest: Color

    // MARK: - Outline
    let outline: Color
    let outlineVariant: Color

    // MARK: - Inverse
    let inverseSurface: Color
    let inverseOnSurface: Color
    let inversePrimary: Color
}

// MARK: - Light Color Scheme

extension HeritageColorScheme {
    static let light = HeritageColorScheme(
        primary: Color(hex: "8F372F"),
        onPrimary: .white,
        primaryContainer: Color(hex: "FFDAD4"),
        onPrimaryContainer: Color(hex: "3A0905"),

        secondary: Color(hex: "6B5852"),
        onSecondary: .white,
        secondaryContainer: Color(hex: "EFE2DC"),
        onSecondaryContainer: Color(hex: "261915"),

        tertiary: Color(hex: "735C23"),
        onTertiary: .white,
        tertiaryContainer: Color(hex: "FFE1A6"),
        onTertiaryContainer: Color(hex: "261A00"),

        background: Color(hex: "FCF8F5"),
        onBackground: Color(hex: "211A18"),
        surface: Color(hex: "FCF8F5"),
        onSurface: Color(hex: "211A18"),
        surfaceVariant: Color(hex: "EADDD7"),
        onSurfaceVariant: Color(hex: "51443F"),

        surfaceContainerLowest: .white,
        surfaceContainerLow: Color(hex: "FBF3EF"),
        surfaceContainer: Color(hex: "F5ECE7"),
        surfaceContainerHigh: Color(hex: "EFE3DE"),
        surfaceContainerHighest: Color(hex: "E8DAD4"),

        outline: Color(hex: "83736D"),
        outlineVariant: Color(hex: "D6C2BA"),

        inverseSurface: Color(hex: "372E2B"),
        inverseOnSurface: Color(hex: "FFEDE8"),
        inversePrimary: Color(hex: "FFB4AA")
    )
}

// MARK: - Dark Color Scheme

extension HeritageColorScheme {
    static let dark = HeritageColorScheme(
        primary: Color(hex: "FFB4AA"),
        onPrimary: Color(hex: "561E19"),
        primaryContainer: Color(hex: "733028"),
        onPrimaryContainer: Color(hex: "FFDAD4"),

        secondary: Color(hex: "D8C2BA"),
        onSecondary: Color(hex: "3B2A25"),
        secondaryContainer: Color(hex: "51403A"),
        onSecondaryContainer: Color(hex: "F5DED6"),

        tertiary: Color(hex: "E2C47C"),
        onTertiary: Color(hex: "3F2E00"),
        tertiaryContainer: Color(hex: "594419"),
        onTertiaryContainer: Color(hex: "FFE1A6"),

        background: Color(hex: "16100E"),
        onBackground: Color(hex: "EDE0DC"),
        surface: Color(hex: "16100E"),
        onSurface: Color(hex: "EDE0DC"),
        surfaceVariant: Color(hex: "51443F"),
        onSurfaceVariant: Color(hex: "D6C2BA"),

        surfaceContainerLowest: Color(hex: "100B09"),
        surfaceContainerLow: Color(hex: "241D1A"),
        surfaceContainer: Color(hex: "2A211E"),
        surfaceContainerHigh: Color(hex: "362B27"),
        surfaceContainerHighest: Color(hex: "433631"),

        outline: Color(hex: "9F8D86"),
        outlineVariant: Color(hex: "5D4C45"),

        inverseSurface: Color(hex: "EDE0DC"),
        inverseOnSurface: Color(hex: "372E2B"),
        inversePrimary: Color(hex: "8F372F")
    )
}
