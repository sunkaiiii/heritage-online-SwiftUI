import SwiftUI

/// 名录引用卡片组件
/// 统一展示 DirectoryReferenceDTO 的卡片样式，用于名录详情和传承人详情的相关内容区块
/// 调用方负责决定是否包裹 NavigationLink
struct DirectoryReferenceCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let ref: DirectoryReferenceDTO

    /// 组装 meta 信息：kind · category · region · year
    private var metaParts: [String] {
        [
            ref.kind.flatMap { ContentLabels.localizedDirectoryKind($0) }.map { String(localized: String.LocalizationValue($0)) },
            ref.category,
            ref.region,
            ref.publishedYear.map { String(format: String(localized: "directory.yearFormat"), $0) }
        ].compactMap { $0 }.filter { !$0.isEmpty }
    }

    var body: some View {
        ContentCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = ref.title, !title.isEmpty {
                        Text(title)
                            .font(HeritageTypography.titleMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(2)
                    }
                    if !metaParts.isEmpty {
                        Text(metaParts.joined(separator: " · "))
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(14)
        }
    }
}
