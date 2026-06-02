import SwiftUI

/// 内容卡片组件
/// Card(surfaceContainerLow)，圆角 8dp，0 elevation
struct ContentCard<Content: View>: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }
}

#Preview {
    ContentCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card Title")
                .font(HeritageTypography.titleMedium)
            Text("Card content goes here")
                .font(HeritageTypography.bodyMedium)
        }
        .padding(16)
    }
    .padding(20)
    .environment(\.heritageColorScheme, .light)
}
