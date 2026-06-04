import SwiftUI

/// 综合推荐区块
/// 对齐 Android BlendedRecommendationsSection
/// 展示标题 + 横向推荐卡片列表
struct BlendedRecommendationsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let recommendations: [BlendedRecommendationItemDTO]
    let onItemClick: (BlendedRecommendationItemDTO) -> Void

    /// 过滤掉空 id 或未知 type 的项
    private var validItems: [BlendedRecommendationItemDTO] {
        recommendations.filter { item in
            !item.id.isEmpty && contextItemTarget(id: item.id, type: item.type) != nil
        }
    }

    var body: some View {
        if validItems.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 4) {
                SectionHeader(title: String(localized: "blended.title"))

                Text(String(localized: "blended.subtitle"))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(validItems.enumerated()), id: \.offset) { _, item in
                            BlendedRecommendationCard(
                                item: item,
                                onClick: { onItemClick(item) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

/// 综合推荐卡片
/// 对齐 Android BlendedRecommendationCard
/// 240dp 宽卡片，展示标题、副标题、元数据、推荐理由和分数条
struct BlendedRecommendationCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: BlendedRecommendationItemDTO
    let onClick: () -> Void

    @State private var showAllReasons = false

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 6) {
                // 标题行 + 进入图标
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(colorScheme.onSurface)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }

                // 副标题
                if let subtitle = item.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(1)
                }

                // 类型 + 分类 + 地区 chips
                FlowLayout(spacing: 4) {
                    if !item.type.isEmpty {
                        MetaChip(LocalizedStringKey(ContentLabels.contentTypeKey(item.type)))
                    }
                    if let category = item.category, !category.isEmpty {
                        if let categoryKey = ContentLabels.articleCategoryKey(category) {
                            MetaChip(LocalizedStringKey(categoryKey))
                        }
                    }
                    if let region = item.region, !region.isEmpty {
                        MetaChip(region)
                    }
                }

                // 推荐理由
                if !item.reasons.isEmpty {
                    Text(String(localized: "blended.reasons"))
                        .font(HeritageTypography.labelMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.primary)

                    let displayReasons = showAllReasons ? item.reasons : Array(item.reasons.prefix(2))
                    ForEach(Array(displayReasons.enumerated()), id: \.offset) { _, reason in
                        Text("• \(reason)")
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    if item.reasons.count > 2 && !showAllReasons {
                        Button(action: { showAllReasons = true }) {
                            Text(String(localized: "blended.showMoreReasons"))
                                .font(HeritageTypography.labelMedium)
                                .foregroundStyle(colorScheme.primary)
                        }
                    }
                }

                // 分数分解条
                ScoreBreakdownBar(breakdown: item.scoreBreakdown)
            }
            .padding(12)
            .frame(width: 240, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

/// 分数分解条
/// 对齐 Android ScoreBreakdownBar
/// 按比例展示 5 个分数维度的堆叠条
private struct ScoreBreakdownBar: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let breakdown: RecommendationScoreBreakdownDTO

    private var total: Double {
        breakdown.explicit + breakdown.inferred + breakdown.embedding + breakdown.sameCategory + breakdown.sameRegion
    }

    var body: some View {
        if total <= 0 {
            EmptyView()
        } else {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "blended.score"))
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            HStack(spacing: 0) {
                if breakdown.explicit > 0 {
                    Rectangle()
                        .fill(colorScheme.primary)
                        .frame(width: max(1, (breakdown.explicit / total) * 200), height: 6)
                }
                if breakdown.inferred > 0 {
                    Rectangle()
                        .fill(colorScheme.secondary)
                        .frame(width: max(1, (breakdown.inferred / total) * 200), height: 6)
                }
                if breakdown.embedding > 0 {
                    Rectangle()
                        .fill(colorScheme.tertiary)
                        .frame(width: max(1, (breakdown.embedding / total) * 200), height: 6)
                }
                if breakdown.sameCategory > 0 {
                    Rectangle()
                        .fill(colorScheme.primaryContainer)
                        .frame(width: max(1, (breakdown.sameCategory / total) * 200), height: 6)
                }
                if breakdown.sameRegion > 0 {
                    Rectangle()
                        .fill(colorScheme.secondaryContainer)
                        .frame(width: max(1, (breakdown.sameRegion / total) * 200), height: 6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        }
    }
}

// MARK: - Context Target Helper

/// 将 id + type 映射为可导航目标
/// 对齐 Android contextItemTarget()
func contextItemTarget(id: String, type: String) -> String? {
    guard !id.isEmpty else { return nil }
    switch type {
    case "article", "directoryItem", "inheritor":
        return type
    default:
        return nil
    }
}

#Preview {
    VStack {
        Text("BlendedRecommendationCard Preview")
            .font(HeritageTypography.headlineMedium)
        // Preview requires backend data; use ComponentPreviewView for live preview
    }
    .padding()
    .heritageTheme()
}
