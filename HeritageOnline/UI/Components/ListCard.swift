import SwiftUI

/// 列表卡片组件
/// 横向图文布局
struct ListCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let title: String
    let subtitle: String?
    let summary: String?
    let imageURL: URL?
    let category: String?
    let date: String?
    let isProminent: Bool

    init(
        title: String,
        subtitle: String? = nil,
        summary: String? = nil,
        imageURL: URL? = nil,
        category: String? = nil,
        date: String? = nil,
        isProminent: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.summary = summary
        self.imageURL = imageURL
        self.category = category
        self.date = date
        self.isProminent = isProminent
    }

    var body: some View {
        ContentCard {
            if isProminent {
                prominentLayout
            } else {
                horizontalLayout
            }
        }
    }

    private var horizontalLayout: some View {
        HStack(spacing: 12) {
            HeritageListImage(urlString: imageURL?.absoluteString, placeholderText: title, width: 100, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                if let category {
                    MetaChip(category)
                        .font(HeritageTypography.labelMedium)
                }

                Text(title)
                    .font(HeritageTypography.titleMedium)
                    .foregroundStyle(colorScheme.onSurface)
                    .lineLimit(2)

                if let subtitle {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(3)
                }

                if let date {
                    Text(date)
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }

            Spacer()
        }
        .padding(14)
    }

    private var prominentLayout: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeritageListImage(urlString: imageURL?.absoluteString, placeholderText: title, width: nil, height: 160)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                if let category {
                    MetaChip(category)
                        .font(HeritageTypography.labelMedium)
                }

                Text(title)
                    .font(HeritageTypography.titleMedium)
                    .foregroundStyle(colorScheme.onSurface)

                if let summary {
                    Text(summary)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(3)
                }

                if let date {
                    Text(date)
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ListCard(
            title: "文章标题示例",
            subtitle: "副标题文本",
            category: "新闻",
            date: "2024-01-15"
        )

        ListCard(
            title: "突出显示的文章标题",
            summary: "这是一段摘要文本，用于展示突出显示的卡片布局效果",
            category: "专题",
            date: "2024-01-15",
            isProminent: true
        )
    }
    .padding(20)
    .environment(\.heritageColorScheme, .light)
}
