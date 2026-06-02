import SwiftUI

/// 事实卡片组件
/// label/value 两列事实表
/// 完全对齐 Android HeritageFactCard
struct FactCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let items: [FactItem]

    struct FactItem: Identifiable {
        let id = UUID()
        let label: String
        let value: String
    }

    var body: some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Text(item.label)
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.primary)
                            .frame(width: 80, alignment: .leading)

                        Text(item.value)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurface)

                        Spacer()
                    }
                }
            }
            .padding(14)
        }
    }
}

#Preview {
    FactCard(items: [
        .init(label: "类别", value: "传统技艺"),
        .init(label: "地区", value: "北京市"),
        .init(label: "批次", value: "第一批"),
        .init(label: "年份", value: "2006")
    ])
    .padding(20)
    .environment(\.heritageColorScheme, .light)
}
