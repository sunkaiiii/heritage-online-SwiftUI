import SwiftUI

/// Heritage 应用形状定义
struct HeritageShapes {
    /// 超小圆角
    static let extraSmall = RoundedRectangle(cornerRadius: 4)

    /// 小圆角
    static let small = RoundedRectangle(cornerRadius: 8)

    /// 中圆角（与 small 相同，保持一致性）
    static let medium = RoundedRectangle(cornerRadius: 8)

    /// 大圆角（与 small 相同，保持一致性）
    static let large = RoundedRectangle(cornerRadius: 8)

    /// 超大圆角（与 small 相同，保持一致性）
    static let extraLarge = RoundedRectangle(cornerRadius: 8)

    /// 圆角值
    static let cornerRadius: CGFloat = 8

    /// 超小圆角值
    static let extraSmallCornerRadius: CGFloat = 4
}
