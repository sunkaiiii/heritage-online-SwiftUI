import SwiftUI

/// 区块标题组件
/// title + divider
struct SectionHeader: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(HeritageTypography.titleLarge)
                .foregroundStyle(colorScheme.onBackground)

            Divider()
                .background(colorScheme.outlineVariant)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

#Preview {
    SectionHeader(title: "最新文章")
        .environment(\.heritageColorScheme, .light)
}
