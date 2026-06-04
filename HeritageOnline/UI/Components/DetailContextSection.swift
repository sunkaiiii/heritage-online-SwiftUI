import SwiftUI

/// 详情 Context 区块点击事件
/// 对齐 Android ContextItemClickEvent
struct ContextItemClickEvent {
    let id: String
    let type: String?
    let source: String
    let title: String?
    let category: String?
    let kind: String?
    let sourceId: String?
    let sourceUrl: String?
}

/// 详情 Context 区块
/// 对齐 Android DetailContextSection
/// 渲染 Related、Recommendations、Semantic Recommendations、Collections、Topics、Graph
struct DetailContextSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let context: DetailContextDTO?
    let isLoading: Bool
    let error: AppError?
    let onRetry: () -> Void
    let onItemClick: (ContextItemClickEvent) -> Void
    let onCollectionClick: (String) -> Void
    let onTopicClick: (String, String) -> Void

    var body: some View {
        if isLoading {
            ContextLoadingPlaceholder()
        } else if let error {
            ContextErrorRow(error: error, onRetry: onRetry)
        } else if let context {
            ContextContent(
                context: context,
                onItemClick: onItemClick,
                onCollectionClick: onCollectionClick,
                onTopicClick: onTopicClick
            )
        }
    }
}

// MARK: - Context Content

private struct ContextContent: View {
    let context: DetailContextDTO
    let onItemClick: (ContextItemClickEvent) -> Void
    let onCollectionClick: (String) -> Void
    let onTopicClick: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Related
            if !context.related.isEmpty {
                ContextRelatedSection(
                    related: context.related,
                    onItemClick: { item in
                        onItemClick(ContextItemClickEvent(
                            id: item.id ?? "", type: item.type, source: "related",
                            title: item.title, category: item.category, kind: item.kind,
                            sourceId: item.sourceId, sourceUrl: item.sourceUrl
                        ))
                    }
                )
            }

            // Recommendations
            if !context.recommendations.isEmpty {
                ContextRecommendationsSection(
                    title: String(localized: "context.recommendations"),
                    recommendations: context.recommendations,
                    onItemClick: { rec in
                        onItemClick(ContextItemClickEvent(
                            id: rec.id ?? "", type: rec.type, source: "recommendation",
                            title: rec.title, category: rec.category, kind: rec.kind,
                            sourceId: rec.sourceId, sourceUrl: rec.sourceUrl
                        ))
                    }
                )
            }

            // Semantic Recommendations
            if !context.semanticRecommendations.isEmpty {
                ContextRecommendationsSection(
                    title: String(localized: "context.semanticRecommendations"),
                    recommendations: context.semanticRecommendations,
                    onItemClick: { rec in
                        onItemClick(ContextItemClickEvent(
                            id: rec.id ?? "", type: rec.type, source: "semanticRecommendation",
                            title: rec.title, category: rec.category, kind: rec.kind,
                            sourceId: rec.sourceId, sourceUrl: rec.sourceUrl
                        ))
                    }
                )
            }

            // Collections
            if !context.collections.isEmpty {
                ContextCollectionsSection(
                    collections: context.collections,
                    onCollectionClick: onCollectionClick
                )
            }

            // Explore Topics
            if !context.exploreTopics.isEmpty {
                ContextTopicsSection(
                    topics: context.exploreTopics,
                    onTopicClick: onTopicClick
                )
            }

            // Graph
            if !context.graph.isEmpty {
                ContextGraphSection(
                    edges: context.graph,
                    onItemClick: { id, type, title in
                        onItemClick(ContextItemClickEvent(
                            id: id, type: type, source: "graph",
                            title: title, category: nil, kind: nil,
                            sourceId: nil, sourceUrl: nil
                        ))
                    }
                )
            }
        }
    }
}

// MARK: - Context Loading / Error

private struct ContextLoadingPlaceholder: View {
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

private struct ContextErrorRow: View {
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

// MARK: - Related Section

private struct ContextRelatedSection: View {
    let related: [RelatedItemDTO]
    let onItemClick: (RelatedItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "context.related"))

            ForEach(Array(related.enumerated()), id: \.offset) { _, item in
                ContextRelatedRow(item: item) {
                    if let id = item.id, !id.isEmpty {
                        onItemClick(item)
                    }
                }
            }
        }
    }
}

private struct ContextRelatedRow: View {
    let item: RelatedItemDTO
    let onClick: () -> Void

    private var metaText: String {
        var parts: [String] = []
        if let category = item.category, !category.isEmpty {
            parts.append(ContentLabels.localizedArticleCategory(category) ?? category)
        }
        if let kind = item.kind, !kind.isEmpty {
            parts.append(ContentLabels.localizedDirectoryKind(kind) ?? kind)
        }
        return parts.joined(separator: " · ")
    }

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(.primary)

                    if !metaText.isEmpty {
                        Text(metaText)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recommendations Section

private struct ContextRecommendationsSection: View {
    let title: String
    let recommendations: [RelatedItemDTO]
    let onItemClick: (RelatedItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(recommendations.enumerated()), id: \.offset) { _, rec in
                        ContextRecommendationCard(recommendation: rec) {
                            if let id = rec.id, !id.isEmpty {
                                onItemClick(rec)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ContextRecommendationCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let recommendation: RelatedItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                if let summary = recommendation.summary, !summary.isEmpty {
                    Text(summary)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                }

                if let category = recommendation.category, !category.isEmpty {
                    if let categoryKey = ContentLabels.articleCategoryKey(category) {
                        MetaChip(LocalizedStringKey(categoryKey))
                    }
                }
            }
            .padding(12)
            .frame(width: 180, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Collections Section

private struct ContextCollectionsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collections: [CollectionRefDTO]
    let onCollectionClick: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "context.collections"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(collections.enumerated()), id: \.offset) { _, collection in
                        ContextCollectionCard(collection: collection) {
                            if let id = collection.id, !id.isEmpty {
                                onCollectionClick(id)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ContextCollectionCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collection: CollectionRefDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                if let subtitle = collection.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(width: 160, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Topics Section

private struct ContextTopicsSection: View {
    let topics: [ExploreTopicRefDTO]
    let onTopicClick: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "context.exploreTopics"))

            FlowLayout(spacing: 8) {
                ForEach(Array(topics.enumerated()), id: \.offset) { _, topic in
                    Button(action: {
                        if let type = topic.type, let key = topic.key {
                            onTopicClick(type, key)
                        }
                    }) {
                        MetaChip(topic.title ?? topic.key ?? "")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Graph Section

private struct ContextGraphSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let edges: [GraphEdgeDTO]
    let onItemClick: (String, String, String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "context.graph"))

            ForEach(Array(edges.enumerated()), id: \.offset) { _, edge in
                GraphEdgeRow(
                    edge: edge,
                    onFromClick: {
                        if let id = edge.fromId, !id.isEmpty {
                            onItemClick(id, edge.fromType ?? "", edge.fromTitle)
                        }
                    },
                    onToClick: {
                        if let id = edge.toId, !id.isEmpty {
                            onItemClick(id, edge.toType ?? "", edge.toTitle)
                        }
                    }
                )
            }
        }
    }
}

private struct GraphEdgeRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let edge: GraphEdgeDTO
    let onFromClick: () -> Void
    let onToClick: () -> Void

    var body: some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 4) {
                // from -> to
                HStack(spacing: 4) {
                    Button(action: onFromClick) {
                        Text(edge.fromTitle ?? "")
                            .font(HeritageTypography.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundStyle(colorScheme.primary)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)

                    Text("→")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)

                    Button(action: onToClick) {
                        Text(edge.toTitle ?? "")
                            .font(HeritageTypography.bodyMedium)
                            .fontWeight(.semibold)
                            .foregroundStyle(colorScheme.primary)
                            .lineLimit(1)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }

                // 关系标签
                if let relation = edge.relation, !relation.isEmpty {
                    Text(relation)
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
            .padding(12)
        }
    }
}
