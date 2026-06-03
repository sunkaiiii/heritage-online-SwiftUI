import SwiftUI

/// 发现项卡片组件
/// 对齐 Android DiscoveryItemCard
/// 用于发现页和其他混合内容列表的统一 item 卡片
struct DiscoveryItemCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DiscoveryItemDTO
    let onClick: () -> Void
    var showImageSlot: Bool = true

    /// 获取最佳图片 URL
    private var bestImageUrl: String? {
        item.coverImage?.displayUrl ?? item.coverImage?.thumbnailUrl ?? item.coverImage?.originalUrl ?? item.coverImage?.sourceUrl
    }

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 0) {
                // 图片区域
                if showImageSlot {
                    if let imageUrl = bestImageUrl {
                        HeritageAsyncImage(
                            urlString: imageUrl,
                            placeholderText: String(item.title.prefix(1))
                        )
                        .frame(height: 118)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                    } else {
                        ZStack {
                            colorScheme.surfaceContainerHighest
                            Text(String(item.title.prefix(1)))
                                .font(HeritageTypography.headlineMedium)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                        }
                        .frame(height: 118)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                    }
                }

                // 文字区域
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(colorScheme.onSurface)

                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    // Meta chips
                    HStack(spacing: 4) {
                        if !item.type.isEmpty {
                            MetaChip(LocalizedContentType(item.type))
                        }
                        if let category = item.category, !category.isEmpty {
                            MetaChip(LocalizedArticleCategory(category))
                        }
                        if let region = item.region, !region.isEmpty {
                            MetaChip(region)
                        }
                    }
                }
                .padding(12)
            }
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .frame(width: 220)
    }
}

/// 发现项行组件
/// 对齐 Android DiscoveryItemRow
/// 用于发现页今日发现等横向布局
struct DiscoveryItemRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DiscoveryItemDTO
    let onClick: () -> Void
    var showImageSlot: Bool = true

    /// 获取最佳图片 URL
    private var bestImageUrl: String? {
        item.coverImage?.displayUrl ?? item.coverImage?.thumbnailUrl ?? item.coverImage?.originalUrl ?? item.coverImage?.sourceUrl
    }

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                // 左侧缩略图
                if showImageSlot {
                    if let imageUrl = bestImageUrl {
                        HeritageAsyncImage(
                            urlString: imageUrl,
                            placeholderText: String(item.title.prefix(1))
                        )
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        ZStack {
                            colorScheme.surfaceContainerHighest
                            Text(String(item.title.prefix(1)))
                                .font(HeritageTypography.titleLarge)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                        }
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // 右侧文字
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(colorScheme.onSurface)

                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    // Meta chips
                    HStack(spacing: 4) {
                        if !item.type.isEmpty {
                            MetaChip(LocalizedContentType(item.type))
                        }
                        if let category = item.category, !category.isEmpty {
                            MetaChip(LocalizedArticleCategory(category))
                        }
                        if let region = item.region, !region.isEmpty {
                            MetaChip(region)
                        }
                    }
                }

                Spacer()
            }
            .padding(12)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Helper Functions

/// 获取本地化的内容类型
private func LocalizedContentType(_ type: String) -> String {
    switch type {
    case "article":
        return String(localized: "contentType.article")
    case "directoryItem":
        return String(localized: "contentType.directoryItem")
    case "inheritor":
        return String(localized: "contentType.inheritor")
    default:
        return type
    }
}

/// 获取本地化的文章分类
private func LocalizedArticleCategory(_ category: String) -> String {
    switch category {
    case "news":
        return String(localized: "articleCategory.news")
    case "forum":
        return String(localized: "articleCategory.forum")
    case "specialTopic":
        return String(localized: "articleCategory.specialTopic")
    default:
        return category
    }
}

#Preview {
    VStack(spacing: 16) {
        DiscoveryItemCard(
            item: DiscoveryItemDTO(
                id: "1",
                type: "article",
                title: "示例文章标题",
                summary: "这是一篇示例文章的摘要",
                category: "news",
                kind: nil,
                region: "北京",
                publishedAt: nil,
                publishedYear: nil,
                coverImage: nil,
                sourceUrl: ""
            ),
            onClick: {}
        )

        DiscoveryItemRow(
            item: DiscoveryItemDTO(
                id: "2",
                type: "directoryItem",
                title: "示例名录标题",
                summary: "这是一个示例名录的摘要",
                category: nil,
                kind: "nationalProject",
                region: "上海",
                publishedAt: nil,
                publishedYear: nil,
                coverImage: nil,
                sourceUrl: ""
            ),
            onClick: {}
        )
    }
    .padding()
    .heritageTheme()
}
