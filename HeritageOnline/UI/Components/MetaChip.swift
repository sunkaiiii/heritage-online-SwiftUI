import SwiftUI

/// Meta 标签组件
/// Surface(surfaceContainerHigh)，圆角 8dp，outlineVariant 边框，10x5 padding
struct MetaChip: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let text: Text
    let isSelected: Bool

    /// 使用纯文本初始化
    init(_ text: String, isSelected: Bool = false) {
        self.text = Text(text)
        self.isSelected = isSelected
    }

    /// 使用本地化 key 初始化（避免提前 String(localized:)）
    init(_ key: LocalizedStringKey, isSelected: Bool = false) {
        self.text = Text(key)
        self.isSelected = isSelected
    }

    var body: some View {
        text
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius)
                    .stroke(colorScheme.outlineVariant, lineWidth: 1)
            )
    }
}

#Preview {
    HStack(spacing: 8) {
        MetaChip("新闻")
        MetaChip("论坛", isSelected: true)
        MetaChip("专题")
    }
    .environment(\.heritageColorScheme, .light)
}
