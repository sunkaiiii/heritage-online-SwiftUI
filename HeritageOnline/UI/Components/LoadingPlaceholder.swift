import SwiftUI

/// 加载占位组件
struct LoadingPlaceholder: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(colorScheme.primary)

            Text("loading.default")
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 列表加载占位组件
struct ListLoadingPlaceholder: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let count: Int

    init(count: Int = 5) {
        self.count = count
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                ContentCard {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius)
                            .fill(colorScheme.surfaceContainerHigh)
                            .frame(width: 100, height: 80)

                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorScheme.surfaceContainerHigh)
                                .frame(height: 16)
                                .frame(maxWidth: .infinity)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorScheme.surfaceContainerHigh)
                                .frame(height: 14)
                                .frame(width: 150)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(colorScheme.surfaceContainerHigh)
                                .frame(height: 12)
                                .frame(width: 100)
                        }

                        Spacer()
                    }
                    .padding(14)
                }
            }
        }
    }
}

#Preview {
    ListLoadingPlaceholder()
        .padding(20)
        .environment(\.heritageColorScheme, .light)
}
