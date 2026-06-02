import SwiftUI

/// Heritage 应用字体定义
/// 完全对齐 Android Material 3 Typography
struct HeritageTypography {
    /// 大标题（少量使用）
    /// 字重: SemiBold, 字号: 34, 行高: 42
    static let displaySmall = Font.system(size: 34, weight: .semibold, design: .default)

    /// 主页面 header title
    /// 字重: SemiBold, 字号: 30, 行高: 38
    static let headlineLarge = Font.system(size: 30, weight: .semibold, design: .default)

    /// 详情页大标题或二级页标题
    /// 字重: SemiBold, 字号: 26, 行高: 34
    static let headlineMedium = Font.system(size: 26, weight: .semibold, design: .default)

    /// 卡片组标题、详情小标题
    /// 字重: SemiBold, 字号: 22, 行高: 30
    static let headlineSmall = Font.system(size: 22, weight: .semibold, design: .default)

    /// SectionHeader 标题
    /// 字重: SemiBold, 字号: 20, 行高: 28
    static let titleLarge = Font.system(size: 20, weight: .semibold, design: .default)

    /// 卡片标题、列表 item 标题
    /// 字重: SemiBold, 字号: 16, 行高: 24
    static let titleMedium = Font.system(size: 16, weight: .semibold, design: .default)

    /// 详情正文
    /// 字重: Normal, 字号: 16, 行高: 27
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)

    /// 摘要、meta、列表正文
    /// 字重: Normal, 字号: 14, 行高: 22
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)

    /// chip、按钮、短标签
    /// 字重: SemiBold, 字号: 14, 行高: 20
    static let labelLarge = Font.system(size: 14, weight: .semibold, design: .default)

    /// 辅助标签
    /// 字重: Medium, 字号: 12, 行高: 16
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
}

// MARK: - Typography Style (包含行高)

/// 字体样式，包含行高信息
struct HeritageTextStyle {
    let font: Font
    let lineSpacing: CGFloat
    let letterSpacing: CGFloat

    /// 大标题
    static let displaySmall = HeritageTextStyle(
        font: HeritageTypography.displaySmall,
        lineSpacing: 8,  // 42 - 34 = 8
        letterSpacing: 0
    )

    /// 主页面 header title
    static let headlineLarge = HeritageTextStyle(
        font: HeritageTypography.headlineLarge,
        lineSpacing: 8,  // 38 - 30 = 8
        letterSpacing: 0
    )

    /// 详情页大标题或二级页标题
    static let headlineMedium = HeritageTextStyle(
        font: HeritageTypography.headlineMedium,
        lineSpacing: 8,  // 34 - 26 = 8
        letterSpacing: 0
    )

    /// 卡片组标题、详情小标题
    static let headlineSmall = HeritageTextStyle(
        font: HeritageTypography.headlineSmall,
        lineSpacing: 8,  // 30 - 22 = 8
        letterSpacing: 0
    )

    /// SectionHeader 标题
    static let titleLarge = HeritageTextStyle(
        font: HeritageTypography.titleLarge,
        lineSpacing: 8,  // 28 - 20 = 8
        letterSpacing: 0
    )

    /// 卡片标题、列表 item 标题
    static let titleMedium = HeritageTextStyle(
        font: HeritageTypography.titleMedium,
        lineSpacing: 8,  // 24 - 16 = 8
        letterSpacing: 0
    )

    /// 详情正文
    static let bodyLarge = HeritageTextStyle(
        font: HeritageTypography.bodyLarge,
        lineSpacing: 11, // 27 - 16 = 11
        letterSpacing: 0
    )

    /// 摘要、meta、列表正文
    static let bodyMedium = HeritageTextStyle(
        font: HeritageTypography.bodyMedium,
        lineSpacing: 8,  // 22 - 14 = 8
        letterSpacing: 0
    )

    /// chip、按钮、短标签
    static let labelLarge = HeritageTextStyle(
        font: HeritageTypography.labelLarge,
        lineSpacing: 6,  // 20 - 14 = 6
        letterSpacing: 0
    )

    /// 辅助标签
    static let labelMedium = HeritageTextStyle(
        font: HeritageTypography.labelMedium,
        lineSpacing: 4,  // 16 - 12 = 4
        letterSpacing: 0
    )
}

// MARK: - View Extension

extension View {
    /// 应用 Heritage 文本样式
    func heritageTextStyle(_ style: HeritageTextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
    }
}

// MARK: - Typography 环境键

private struct HeritageTypographyKey: EnvironmentKey {
    static let defaultValue = HeritageTypography.self
}

extension EnvironmentValues {
    var heritageTypography: HeritageTypography.Type {
        get { self[HeritageTypographyKey.self] }
        set { self[HeritageTypographyKey.self] = newValue }
    }
}
