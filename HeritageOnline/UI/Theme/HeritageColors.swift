import SwiftUI

/// Heritage 应用颜色定义
/// 使用 Material 3 色彩系统
struct HeritageColors {
    // MARK: - Light Theme Colors

    /// 主品牌色
    static let primaryLight = Color(hex: "8F372F")
    /// primary 上的文字/图标
    static let onPrimaryLight = Color.white
    /// 选中态背景、轻量强调容器
    static let primaryContainerLight = Color(hex: "FFDAD4")
    /// primaryContainer 上文字
    static let onPrimaryContainerLight = Color(hex: "3A0905")

    /// 次级强调
    static let secondaryLight = Color(hex: "6B5852")
    /// 次级 chip/card 背景
    static let secondaryContainerLight = Color(hex: "EFE2DC")

    /// 少量第三强调，如统计/趋势
    static let tertiaryLight = Color(hex: "735C23")
    /// 第三强调容器
    static let tertiaryContainerLight = Color(hex: "FFE1A6")

    /// 全页背景
    static let backgroundLight = Color(hex: "FCF8F5")
    /// 默认 surface
    static let surfaceLight = Color(hex: "FCF8F5")
    /// 最高亮容器
    static let surfaceContainerLowestLight = Color.white
    /// 普通卡片和底部导航背景
    static let surfaceContainerLowLight = Color(hex: "FBF3EF")
    /// 中层容器
    static let surfaceContainerLight = Color(hex: "F5ECE7")
    /// chip、图片占位、强调容器
    static let surfaceContainerHighLight = Color(hex: "EFE3DE")
    /// 最深浅色容器
    static let surfaceContainerHighestLight = Color(hex: "E8DAD4")

    /// 正文标题文字
    static let onSurfaceLight = Color(hex: "211A18")
    /// 次级正文、meta 文案
    static let onSurfaceVariantLight = Color(hex: "51443F")
    /// 边框
    static let outlineLight = Color(hex: "83736D")
    /// 分割线、轻边框
    static let outlineVariantLight = Color(hex: "D6C2BA")

    // MARK: - Dark Theme Colors

    /// 暗色主强调
    static let primaryDark = Color(hex: "FFB4AA")
    /// primary 上文字
    static let onPrimaryDark = Color(hex: "561E19")
    /// 暗色选中态背景
    static let primaryContainerDark = Color(hex: "733028")
    /// primaryContainer 上文字
    static let onPrimaryContainerDark = Color(hex: "FFDAD4")

    /// 次级强调
    static let secondaryDark = Color(hex: "D8C2BA")
    /// 次级容器
    static let secondaryContainerDark = Color(hex: "51403A")

    /// 第三强调
    static let tertiaryDark = Color(hex: "E2C47C")
    /// 第三强调容器
    static let tertiaryContainerDark = Color(hex: "594419")

    /// 全页背景
    static let backgroundDark = Color(hex: "16100E")
    /// 默认 surface
    static let surfaceDark = Color(hex: "16100E")
    /// 最暗容器
    static let surfaceContainerLowestDark = Color(hex: "100B09")
    /// 普通卡片和底部导航背景
    static let surfaceContainerLowDark = Color(hex: "241D1A")
    /// 中层容器
    static let surfaceContainerDark = Color(hex: "2A211E")
    /// chip、图片占位
    static let surfaceContainerHighDark = Color(hex: "362B27")
    /// 最亮暗色容器
    static let surfaceContainerHighestDark = Color(hex: "433631")

    /// 正文标题文字
    static let onSurfaceDark = Color(hex: "EDE0DC")
    /// 次级正文、meta 文案
    static let onSurfaceVariantDark = Color(hex: "D6C2BA")
    /// 边框
    static let outlineDark = Color(hex: "9F8D86")
    /// 分割线、轻边框
    static let outlineVariantDark = Color(hex: "5D4C45")
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
