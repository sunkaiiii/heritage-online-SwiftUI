import SwiftUI

/// Meta 标签组件
/// Surface(surfaceContainerHigh)，圆角 8dp，outlineVariant 边框，10x5 padding
struct MetaChip: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let text: String
    let isSelected: Bool

    init(_ text: String, isSelected: Bool = false) {
        self.text = text
        self.isSelected = isSelected
    }

    var body: some View {
        Text(text)
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant)
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
