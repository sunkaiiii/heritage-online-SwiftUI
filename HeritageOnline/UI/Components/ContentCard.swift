import SwiftUI

/// 内容卡片组件
/// Card(surfaceContainerLow)，圆角 8dp，0 elevation
/// 完全对齐 Android HeritageContentCard
struct ContentCard<Content: View>: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let onClick: (() -> Void)?
    let content: () -> Content

    init(onClick: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.onClick = onClick
        self.content = content
    }

    var body: some View {
        if let onClick {
            Button(action: onClick) {
                cardContent
            }
            .buttonStyle(.plain)
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        content()
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }
}

#Preview {
    VStack(spacing: 16) {
        ContentCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("普通卡片")
                    .font(HeritageTypography.titleMedium)
                Text("卡片内容")
                    .font(HeritageTypography.bodyMedium)
            }
            .padding(16)
        }

        ContentCard(onClick: {}) {
            VStack(alignment: .leading, spacing: 8) {
                Text("可点击卡片")
                    .font(HeritageTypography.titleMedium)
                Text("点击查看详情")
                    .font(HeritageTypography.bodyMedium)
            }
            .padding(16)
        }
    }
    .padding(20)
    .environment(\.heritageColorScheme, .light)
}
