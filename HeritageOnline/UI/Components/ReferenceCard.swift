import SwiftUI

/// 引用卡片组件
/// 用于相关内容展示
struct ReferenceCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let title: String
    let subtitle: String?
    let type: String?
    let imageURL: URL?

    var body: some View {
        ContentCard {
            HStack(spacing: 12) {
                if let imageURL {
                    HeritageListImage(urlString: imageURL.absoluteString, placeholderText: title, width: 60, height: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let type {
                        Text(type)
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.primary)
                    }

                    Text(title)
                        .font(HeritageTypography.titleMedium)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    if let subtitle {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(12)
        }
    }
}

#Preview {
    ReferenceCard(
        title: "相关文章标题",
        subtitle: "文章摘要文本",
        type: "文章",
        imageURL: nil
    )
    .padding(20)
    .environment(\.heritageColorScheme, .light)
}
