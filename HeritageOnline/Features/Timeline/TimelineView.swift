import SwiftUI

/// 时间线页面
/// 对齐 Android TimelineScreen
/// 按年份浏览混合内容，支持类型筛选和分页加载
struct TimelineView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel = TimelineViewModel()

    /// 子导航状态
    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?

    var body: some View {
        PageBackground {
            ZStack {
                // 加载中且无数据
                if viewModel.isLoading && viewModel.years.isEmpty {
                    LoadingPlaceholder()
                }
                // 错误且无年份数据
                else if let error = viewModel.error, viewModel.years.isEmpty {
                    TimelineErrorContent(
                        error: error,
                        onRetry: { viewModel.loadYears() }
                    )
                }
                // 正常内容
                else {
                    TimelineContent(
                        viewModel: viewModel,
                        onItemClick: { item in
                            handleItemClick(item)
                        }
                    )
                }
            }
        }
        .navigationTitle("page.timeline")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .task {
            if viewModel.years.isEmpty && viewModel.error == nil {
                viewModel.loadYears()
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
    }

    /// 处理内容项点击
    private func handleItemClick(_ item: TimelineItemDTO) {
        guard let id = item.id, !id.isEmpty else { return }
        switch item.type {
        case "article":
            navigateToArticle = id
        case "directoryItem":
            navigateToDirectory = id
        case "inheritor":
            navigateToInheritor = id
        default:
            break
        }
    }
}

// MARK: - 时间线内容

/// 时间线内容（无状态）
private struct TimelineContent: View {
    let viewModel: TimelineViewModel
    let onItemClick: (TimelineItemDTO) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 年份选择器
            if !viewModel.years.isEmpty {
                TimelineYearSelector(
                    years: viewModel.years,
                    selectedYear: viewModel.selectedYear,
                    onSelectYear: { year in
                        viewModel.selectYear(year)
                    }
                )
            }

            // 类型筛选
            if !viewModel.facets.isEmpty && viewModel.selectedYear != nil {
                TimelineTypeFilter(
                    facets: viewModel.facets,
                    selectedTypes: viewModel.selectedTypes,
                    onToggleType: { type in
                        viewModel.toggleType(type)
                    }
                )
            }

            // 内容区域
            if viewModel.isLoading && viewModel.items.isEmpty {
                // 加载内容中
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.error, viewModel.items.isEmpty {
                // 内容加载错误
                TimelineErrorContent(
                    error: error,
                    onRetry: { viewModel.retryLoad() }
                )
            } else if viewModel.selectedYear == nil {
                // 未选择年份
                TimelineEmptyGuide()
            } else if viewModel.items.isEmpty && !viewModel.isLoading {
                // 空列表
                TimelineEmptyContent()
            } else {
                // 内容列表
                TimelineItemsList(
                    items: viewModel.items,
                    hasMore: viewModel.hasMore,
                    isLoadingMore: viewModel.isLoadingMore,
                    onLoadMore: { viewModel.loadMore() },
                    onItemClick: onItemClick
                )
            }
        }
    }
}

// MARK: - 年份选择器

/// 时间线年份选择器
private struct TimelineYearSelector: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let years: [TimelineYearBucketDTO]
    let selectedYear: Int?
    let onSelectYear: (Int?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(years.enumerated()), id: \.offset) { _, bucket in
                        let isSelected = selectedYear == bucket.year
                        Button {
                            onSelectYear(isSelected ? nil : bucket.year)
                        } label: {
                            VStack(spacing: 4) {
                                Text("\(bucket.year)")
                                    .font(HeritageTypography.labelLarge)
                                    .fontWeight(isSelected ? .bold : .regular)
                                    .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface)

                                // 分类数量
                                HStack(spacing: 6) {
                                    HStack(spacing: 2) {
                                        Text(String(localized: "contentType.article.short"))
                                            .font(HeritageTypography.labelMedium)
                                        Text("\(bucket.articleCount ?? 0)")
                                            .font(HeritageTypography.labelMedium)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer.opacity(0.8) : colorScheme.onSurfaceVariant)

                                    HStack(spacing: 2) {
                                        Text(String(localized: "contentType.directoryItem.short"))
                                            .font(HeritageTypography.labelMedium)
                                        Text("\(bucket.directoryItemCount ?? 0)")
                                            .font(HeritageTypography.labelMedium)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer.opacity(0.8) : colorScheme.onSurfaceVariant)

                                    HStack(spacing: 2) {
                                        Text(String(localized: "contentType.inheritor.short"))
                                            .font(HeritageTypography.labelMedium)
                                        Text("\(bucket.inheritorCount ?? 0)")
                                            .font(HeritageTypography.labelMedium)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer.opacity(0.8) : colorScheme.onSurfaceVariant)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? colorScheme.primary : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 类型筛选

/// 时间线类型筛选行
private struct TimelineTypeFilter: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let facets: [FacetBucketDTO]
    let selectedTypes: Set<SearchResultType>
    let onToggleType: (SearchResultType) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(facets.enumerated()), id: \.offset) { _, facet in
                    if let key = facet.key,
                       let type = SearchResultType(rawValue: key) {
                        let isSelected = selectedTypes.contains(type)
                        let label = String(localized: String.LocalizationValue(ContentLabels.timelineTypeKey(key) ?? key))

                        Button {
                            onToggleType(type)
                        } label: {
                            HStack(spacing: 4) {
                                Text(label)
                                    .font(HeritageTypography.labelLarge)
                                Text("(\(facet.count))")
                                    .font(HeritageTypography.labelMedium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? colorScheme.primary : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - 时间线内容列表

/// 时间线内容列表
private struct TimelineItemsList: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let items: [TimelineItemDTO]
    let hasMore: Bool
    let isLoadingMore: Bool
    let onLoadMore: () -> Void
    let onItemClick: (TimelineItemDTO) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    TimelineItemRow(item: item) {
                        onItemClick(item)
                    }
                }

                // 底部加载更多
                if isLoadingMore {
                    ProgressView()
                        .padding(.vertical, 16)
                } else if hasMore {
                    Button {
                        onLoadMore()
                    } label: {
                        Text(String(localized: "search.loadMore"))
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - 时间线条目行

/// 时间线条目行
/// 左侧年份，右侧内容卡片
private struct TimelineItemRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: TimelineItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(alignment: .top, spacing: 12) {
                // 左侧年份
                VStack(spacing: 2) {
                    if let year = item.year {
                        Text("\(year)")
                            .font(HeritageTypography.titleMedium)
                            .fontWeight(.bold)
                            .foregroundStyle(colorScheme.primary)
                    }

                    if let type = item.type {
                        Text(LocalizedStringKey(ContentLabels.timelineTypeKey(type) ?? type))
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
                .frame(width: 60)

                // 分隔线
                Rectangle()
                    .fill(colorScheme.outlineVariant)
                    .frame(width: 1)

                // 右侧内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    // Meta chips
                    HStack(spacing: 4) {
                        if let category = item.category, !category.isEmpty {
                            MetaChip(LocalizedStringKey(ContentLabels.articleCategoryKey(category) ?? category))
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

// MARK: - 空状态

/// 未选择年份引导
private struct TimelineEmptyGuide: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(String(localized: "timeline.selectYear"))
                .font(HeritageTypography.bodyLarge)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

/// 空内容
private struct TimelineEmptyContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(String(localized: "empty.noContent"))
                .font(HeritageTypography.bodyLarge)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - 错误内容

/// 时间线错误内容
private struct TimelineErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

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

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Identifiable / Hashable Extensions

extension TimelineYearBucketDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(year)
    }

    public static func == (lhs: TimelineYearBucketDTO, rhs: TimelineYearBucketDTO) -> Bool {
        lhs.year == rhs.year
    }
}

#Preview {
    NavigationStack {
        TimelineView()
    }
    .heritageTheme()
}
