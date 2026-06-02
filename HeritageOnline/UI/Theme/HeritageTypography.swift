import SwiftUI

/// Heritage 应用字体定义
struct HeritageTypography {
    /// 大标题（少量使用）
    static let displaySmall = Font.system(size: 34, weight: .semibold, design: .default)

    /// 主页面 header title
    static let headlineLarge = Font.system(size: 30, weight: .semibold, design: .default)

    /// 详情页大标题或二级页标题
    static let headlineMedium = Font.system(size: 26, weight: .semibold, design: .default)

    /// 卡片组标题、详情小标题
    static let headlineSmall = Font.system(size: 22, weight: .semibold, design: .default)

    /// SectionHeader 标题
    static let titleLarge = Font.system(size: 20, weight: .semibold, design: .default)

    /// 卡片标题、列表 item 标题
    static let titleMedium = Font.system(size: 16, weight: .semibold, design: .default)

    /// 详情正文
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)

    /// 摘要、meta、列表正文
    static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)

    /// chip、按钮、短标签
    static let labelLarge = Font.system(size: 14, weight: .semibold, design: .default)

    /// 辅助标签
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
}

/// Typography 环境键
private struct HeritageTypographyKey: EnvironmentKey {
    static let defaultValue = HeritageTypography.self
}

extension EnvironmentValues {
    var heritageTypography: HeritageTypography.Type {
        get { self[HeritageTypographyKey.self] }
        set { self[HeritageTypographyKey.self] = newValue }
    }
}
