import SwiftUI

/// 地区详情页
/// 对齐 Android RegionDetailScreen
/// 展示地区统计、分类/种类 breakdown、精选内容、相关文章、相关地区
struct RegionDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: RegionDetailViewModel

    /// 子导航状态
    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?
    @State private var navigateToRelatedRegion: String?

    init(region: String) {
        _viewModel = State(initialValue: RegionDetailViewModel(region: region))
    }

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.isLoading && viewModel.detail == nil {
                    LoadingPlaceholder()
                } else if let error = viewModel.error, viewModel.detail == nil {
                    RegionDetailErrorContent(
                        error: error,
                        onRetry: { viewModel.loadDetail() }
                    )
                } else if let detail = viewModel.detail {
                    RegionDetailContent(
                        detail: detail,
                        onArticleClick: { id in navigateToArticle = id },
                        onDirectoryClick: { id in navigateToDirectory = id },
                        onInheritorClick: { id in navigateToInheritor = id },
                        onRelatedRegionClick: { region in navigateToRelatedRegion = region }
                    )
                }
            }
        }
        .navigationTitle(viewModel.detail?.displayName ?? viewModel.detail?.region ?? "")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadDetail()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.detail == nil && viewModel.error == nil {
                viewModel.loadDetail()
            }
        }
        // 子导航
        .navigationDestination(item: $navigateToArticle) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToDirectory) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToInheritor) { id in
            InheritorDetailView(inheritorId: id)
        }
        .navigationDestination(item: $navigateToRelatedRegion) { region in
            RegionDetailView(region: region)
        }
    }
}

// MARK: - 地区详情内容

private struct RegionDetailContent: View {
    let detail: RegionAtlasDetailDTO
    let onArticleClick: (String) -> Void
    let onDirectoryClick: (String) -> Void
    let onInheritorClick: (String) -> Void
    let onRelatedRegionClick: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // 统计
                if let stats = detail.stats {
                    RegionDetailStatsRow(stats: stats)
                        .padding(.horizontal, 16)
                }

                // 分类 breakdown
                if !detail.categoryBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "region.categoryBreakdown"))
                            .padding(.horizontal, 16)
                        BreakdownRow(buckets: detail.categoryBreakdown)
                    }
                }

                // 种类 breakdown
                if !detail.kindBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "region.kindBreakdown"))
                            .padding(.horizontal, 16)
                        BreakdownRow(buckets: detail.kindBreakdown)
                    }
                }

                // 精选名录
                if !detail.featuredDirectoryItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "region.featuredItems"))
                            .padding(.horizontal, 16)
                        ForEach(Array(detail.featuredDirectoryItems.enumerated()), id: \.offset) { _, item in
                            DirectoryItemRow(item: item) {
                                if let id = item.id { onDirectoryClick(id) }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // 精选传承人
                if !detail.featuredInheritors.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "region.featuredInheritors"))
                            .padding(.horizontal, 16)
                        ForEach(Array(detail.featuredInheritors.enumerated()), id: \.offset) { _, inheritor in
                            InheritorRow(inheritor: inheritor) {
                                if let id = inheritor.id { onInheritorClick(id) }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // 相关文章
                if !detail.relatedArticles.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "articleDetail.relatedArticles"))
                            .padding(.horizontal, 16)
                        ForEach(Array(detail.relatedArticles.enumerated()), id: \.offset) { _, article in
                            ArticleRow(article: article) {
                                if let id = article.id { onArticleClick(id) }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // 相关地区
                if !detail.relatedRegions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "region.relatedRegions"))
                            .padding(.horizontal, 16)
                        FlowLayout(spacing: 8) {
                            ForEach(Array(detail.relatedRegions.enumerated()), id: \.offset) { _, region in
                                Button {
                                    if let key = region.key { onRelatedRegionClick(key) }
                                } label: {
                                    MetaChip(region.title ?? region.key ?? "")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // 底部间距
                Spacer()
                    .frame(height: 18)
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - 统计行

private struct RegionDetailStatsRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let stats: RegionAtlasDetailStatsDTO

    var body: some View {
        HStack(spacing: 12) {
            StatChip(count: stats.directoryItemCount, label: String(localized: "region.totalDirectory"))
            StatChip(count: stats.inheritorCount, label: String(localized: "region.totalInheritors"))
            StatChip(count: stats.total, label: String(localized: "stats.total"))
        }
    }
}

private struct StatChip: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(HeritageTypography.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme.primary)

            Text(label)
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(colorScheme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Breakdown 行

private struct BreakdownRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let buckets: [FacetBucketDTO]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(buckets.enumerated()), id: \.offset) { _, bucket in
                    VStack(spacing: 2) {
                        Text(bucket.key ?? "")
                            .font(HeritageTypography.labelLarge)
                            .fontWeight(.semibold)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(1)

                        Text("\(bucket.count)")
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(colorScheme.surfaceContainerLow)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - 名录行

private struct DirectoryItemRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DirectoryItemSummaryDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        if let kind = item.kind {
                            MetaChip(LocalizedStringKey(ContentLabels.directoryKindKey(kind) ?? kind))
                        }
                        if let region = item.region, !region.isEmpty {
                            MetaChip(region)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(14)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 传承人行

private struct InheritorRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let inheritor: InheritorSummaryDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(inheritor.name ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        if let project = inheritor.projectName, !project.isEmpty {
                            MetaChip(project)
                        }
                        if let region = inheritor.region, !region.isEmpty {
                            MetaChip(region)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(14)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 文章行

private struct ArticleRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let article: ArticleSummaryDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(article.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    if let summary = article.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(14)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 错误内容

private struct RegionDetailErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button("action.retry") {
                onRetry()
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    NavigationStack {
        RegionDetailView(region: "北京")
    }
    .heritageTheme()
}
