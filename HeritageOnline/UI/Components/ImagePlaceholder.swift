import SwiftUI

/// 图片占位组件
/// 圆角 8dp，占位背景 surfaceContainerHigh，中间粗体 label
struct ImagePlaceholder: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let label: String
    let width: CGFloat?
    let height: CGFloat?

    init(label: String = "E迹", width: CGFloat? = nil, height: CGFloat? = nil) {
        self.label = label
        self.width = width
        self.height = height
    }

    var body: some View {
        ZStack {
            colorScheme.surfaceContainerHigh

            Text(label)
                .font(HeritageTypography.titleMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }
}

#Preview {
    ImagePlaceholder(label: "E迹", width: 120, height: 80)
        .environment(\.heritageColorScheme, .light)
}
