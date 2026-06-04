import SwiftUI

/// 详情页底部探索区导航目标
enum DetailExploreTarget {
    case article(id: String)
    case directoryItem(id: String)
    case inheritor(id: String)
    case collection(id: String)
    case topic(type: String, key: String)
}

/// 详情页底部探索区点击事件
struct DetailExploreTargetClick {
    let target: DetailExploreTarget
    let source: ReadingPathSource
    let title: String?
    let subtitle: String?
    let category: String?
    let region: String?
    let kind: String?
    let sourceId: String?
    let sourceUrl: String?
    let imageUrl: String?

    init(
        target: DetailExploreTarget,
        source: ReadingPathSource,
        title: String? = nil,
        subtitle: String? = nil,
        category: String? = nil,
        region: String? = nil,
        kind: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        imageUrl: String? = nil
    ) {
        self.target = target
        self.source = source
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.region = region
        self.kind = kind
        self.sourceId = sourceId
        self.sourceUrl = sourceUrl
        self.imageUrl = imageUrl
    }

    /// 目标内容类型（用于阅读路径记录）
    var targetContentType: SavedContentType? {
        switch target {
        case .article: .article
        case .directoryItem: .directoryItem
        case .inheritor: .inheritor
        case .collection, .topic: nil
        }
    }

    /// 目标 ID（用于阅读路径记录）
    var targetId: String? {
        switch target {
        case .article(let id): id
        case .directoryItem(let id): id
        case .inheritor(let id): id
        case .collection, .topic: nil
        }
    }
}

/// 统一的详情页底部探索组件
/// 对齐 Android DetailExploreSection
/// 顺序：Digest -> Blended -> Related -> Recommendations -> Semantic -> Graph -> Collections -> Topics
struct DetailExploreSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    // Digest
    let digest: ContentDigestDTO?
    let digestLoading: Bool
    let digestError: AppError?
    let onDigestRetry: () -> Void

    // Blended Recommendations
    let blendedRecommendations: [BlendedRecommendationItemDTO]

    // Context
    let context: DetailContextDTO?
    let contextLoading: Bool
    let contextError: AppError?
    let onContextRetry: () -> Void

    // Navigation
    let onExploreTargetClick: (DetailExploreTargetClick) -> Void

    /// 空壳隐藏检查
    private var hasAnyContent: Bool {
        let hasDigest = digest != nil || digestLoading || digestError != nil
        let hasBlended = !blendedRecommendations.isEmpty
        let hasContext = context != nil || contextLoading || contextError != nil
        return hasDigest || hasBlended || hasContext
    }

    var body: some View {
        if !hasAnyContent {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 16) {
                // 总标题
                SectionHeader(title: String(localized: "detail.explore.title"))

                Text(String(localized: "detail.explore.subtitle"))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.horizontal, 16)

                // 1. Digest 速览
                if let digest {
                    DigestCard(digest: digest)
                } else if digestLoading {
                    ExploreLoadingPlaceholder()
                } else if let digestError {
                    ExploreErrorRetryRow(error: digestError, onRetry: onDigestRetry)
                }

                // 2. 综合推荐
                if !blendedRecommendations.isEmpty {
                    BlendedRecommendationsSection(
                        recommendations: blendedRecommendations,
                        onItemClick: { item in
                            handleBlendedItemClick(item)
                        }
                    )
                }

                // 3-8. Context 区块
                DetailContextSection(
                    context: context,
                    isLoading: contextLoading,
                    error: contextError,
                    onRetry: onContextRetry,
                    onItemClick: { event in
                        handleContextItemClick(event)
                    },
                    onCollectionClick: { collectionId in
                        onExploreTargetClick(DetailExploreTargetClick(
                            target: .collection(id: collectionId),
                            source: .related
                        ))
                    },
                    onTopicClick: { type, key in
                        onExploreTargetClick(DetailExploreTargetClick(
                            target: .topic(type: type, key: key),
                            source: .related
                        ))
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 18)
        }
    }

    /// 处理综合推荐项点击
    private func handleBlendedItemClick(_ item: BlendedRecommendationItemDTO) {
        guard let type = contextItemTarget(id: item.id, type: item.type) else { return }
        let target: DetailExploreTarget
        switch type {
        case "article": target = .article(id: item.id)
        case "directoryItem": target = .directoryItem(id: item.id)
        case "inheritor": target = .inheritor(id: item.id)
        default: return
        }
        onExploreTargetClick(DetailExploreTargetClick(
            target: target,
            source: .blendedRecommendation,
            title: item.title,
            subtitle: item.subtitle,
            category: item.category,
            region: item.region,
            imageUrl: item.coverImage?.displayUrl
        ))
    }

    /// 处理 Context 项点击
    private func handleContextItemClick(_ event: ContextItemClickEvent) {
        guard let type = contextItemTarget(id: event.id, type: event.type ?? "") else { return }
        let target: DetailExploreTarget
        switch type {
        case "article": target = .article(id: event.id)
        case "directoryItem": target = .directoryItem(id: event.id)
        case "inheritor": target = .inheritor(id: event.id)
        default: return
        }
        let source: ReadingPathSource
        switch event.source {
        case "recommendation": source = .recommendation
        case "semanticRecommendation": source = .semanticRecommendation
        case "graph": source = .graph
        default: source = .related
        }
        onExploreTargetClick(DetailExploreTargetClick(
            target: target,
            source: source,
            title: event.title,
            category: event.category,
            kind: event.kind,
            sourceId: event.sourceId,
            sourceUrl: event.sourceUrl
        ))
    }
}

// MARK: - Helper Views

private struct ExploreLoadingPlaceholder: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        ContentCard {
            Text(String(localized: "loading.default"))
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .padding(16)
        }
    }
}

private struct ExploreErrorRetryRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        ContentCard {
            HStack {
                Text(error.localizedDescription)
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .lineLimit(2)

                Spacer()

                Button(action: onRetry) {
                    Text(String(localized: "action.retry"))
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.primary)
                }
            }
            .padding(14)
        }
    }
}
