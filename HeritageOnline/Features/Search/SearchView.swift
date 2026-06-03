import SwiftUI

/// 搜索页主视图
/// 对齐 Android SearchScreen
/// 实现搜索建议、搜索结果、筛选功能
struct SearchView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel = SearchViewModel()

    let initialQuery: String
    let onBack: () -> Void
    let onArticleSelected: (String) -> Void
    let onDirectoryItemSelected: (String) -> Void
    let onInheritorSelected: (String) -> Void

    @State private var showFilterSheet = false

    var body: some View {
        PageBackground {
            VStack(spacing: 0) {
                // 顶部搜索栏
                SearchTopBar(
                    query: viewModel.uiState.query,
                    onQueryChange: { viewModel.updateQuery($0) },
                    onSearch: { viewModel.search() },
                    onBack: onBack,
                    onFilterClick: { showFilterSheet = true },
                    activeFilterCount: viewModel.uiState.activeFilterCount
                )

                // 建议列表
                if !viewModel.uiState.suggestions.isEmpty && !viewModel.uiState.query.isEmpty {
                    SuggestionsList(
                        suggestions: viewModel.uiState.suggestions,
                        onSuggestionSelected: { viewModel.selectSuggestion($0) }
                    )
                }

                // 活跃筛选条件
                if viewModel.uiState.hasActiveFilters {
                    ActiveFiltersRow(
                        uiState: viewModel.uiState,
                        onToggleType: { viewModel.toggleType($0) },
                        onClearRegion: { viewModel.updateRegionFilter("") },
                        onClearCategory: { viewModel.updateCategoryFilter("") },
                        onClearYear: { viewModel.updateYearFilter(nil) },
                        onClearKind: { viewModel.updateKindFilter(nil) },
                        onClearHasImage: { viewModel.updateHasImageFilter(nil) },
                        onClearAll: { viewModel.clearFilters() }
                    )
                }

                // 结果区域
                ZStack {
                    if viewModel.uiState.isSearching {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.uiState.error, viewModel.uiState.results.isEmpty {
                        SearchErrorContent(
                            error: error,
                            onRetry: { viewModel.search() },
                            onClearError: { viewModel.clearError() }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.uiState.results.isEmpty && !viewModel.uiState.query.isEmpty && !viewModel.uiState.isSearching {
                        SearchEmptyContent()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if !viewModel.uiState.results.isEmpty {
                        SearchResultsList(
                            results: viewModel.uiState.results,
                            total: viewModel.uiState.total,
                            isLoadingMore: viewModel.uiState.isLoadingMore,
                            hasMore: viewModel.uiState.hasMore,
                            onResultClick: { item in
                                guard let id = item.id else { return }
                                switch item.type {
                                case "article":
                                    onArticleSelected(id)
                                case "directoryItem":
                                    onDirectoryItemSelected(id)
                                case "inheritor":
                                    onInheritorSelected(id)
                                default:
                                    break
                                }
                            },
                            onLoadMore: { viewModel.loadMore() }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("page.search")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            if !initialQuery.isEmpty {
                viewModel.updateQuery(initialQuery)
                viewModel.search()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            SearchFilterSheet(
                uiState: viewModel.uiState,
                onToggleType: { viewModel.toggleType($0) },
                onUpdateRegion: { viewModel.updateRegionFilter($0) },
                onUpdateCategory: { viewModel.updateCategoryFilter($0) },
                onUpdateYear: { viewModel.updateYearFilter($0) },
                onUpdateKind: { viewModel.updateKindFilter($0) },
                onUpdateHasImage: { viewModel.updateHasImageFilter($0) },
                onClearAll: { viewModel.clearFilters() },
                onDismiss: { showFilterSheet = false }
            )
        }
    }
}

// MARK: - Search Top Bar

private struct SearchTopBar: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let query: String
    let onQueryChange: (String) -> Void
    let onSearch: () -> Void
    let onBack: () -> Void
    let onFilterClick: () -> Void
    let activeFilterCount: Int

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(colorScheme.onSurface)
            }

            SearchField(
                text: Binding(
                    get: { query },
                    set: { onQueryChange($0) }
                ),
                placeholder: "discovery.searchPlaceholder",
                onSubmit: onSearch
            )

            if activeFilterCount > 0 {
                Badge(count: activeFilterCount)
            }

            Button(action: onFilterClick) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 18))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

// MARK: - Badge

private struct Badge: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(HeritageTypography.labelMedium)
            .fontWeight(.bold)
            .foregroundStyle(colorScheme.onError)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(colorScheme.error)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Suggestions List

private struct SuggestionsList: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let suggestions: [SearchSuggestionDTO]
    let onSuggestionSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(suggestions, id: \.text) { suggestion in
                if let text = suggestion.text, !text.isEmpty {
                    Button(action: { onSuggestionSelected(text) }) {
                        Text(text)
                            .font(HeritageTypography.bodyLarge)
                            .foregroundStyle(colorScheme.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)

                    Divider()
                        .background(colorScheme.outlineVariant)
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(colorScheme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}

// MARK: - Active Filters Row

private struct ActiveFiltersRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let uiState: SearchUiState
    let onToggleType: (SearchResultType) -> Void
    let onClearRegion: () -> Void
    let onClearCategory: () -> Void
    let onClearYear: () -> Void
    let onClearKind: () -> Void
    let onClearHasImage: () -> Void
    let onClearAll: () -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(uiState.selectedTypes), id: \.self) { type in
                FilterChip(
                    text: localizedSearchResultType(type),
                    isSelected: true,
                    onRemove: { onToggleType(type) }
                )
            }

            if !uiState.regionFilter.isEmpty {
                FilterChip(
                    text: uiState.regionFilter,
                    isSelected: true,
                    onRemove: onClearRegion
                )
            }

            if !uiState.categoryFilter.isEmpty {
                FilterChip(
                    text: uiState.categoryFilter,
                    isSelected: true,
                    onRemove: onClearCategory
                )
            }

            if let year = uiState.yearFilter {
                FilterChip(
                    text: "\(year)",
                    isSelected: true,
                    onRemove: onClearYear
                )
            }

            if let kind = uiState.kindFilter {
                FilterChip(
                    text: localizedDirectoryKind(kind),
                    isSelected: true,
                    onRemove: onClearKind
                )
            }

            if let hasImage = uiState.hasImageFilter {
                FilterChip(
                    text: hasImage ? String(localized: "filter.hasImage") : String(localized: "filter.noImage"),
                    isSelected: true,
                    onRemove: onClearHasImage
                )
            }

            Button(action: onClearAll) {
                Text(String(localized: "filter.clear"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let text: String
    let isSelected: Bool
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(HeritageTypography.labelMedium)
                .lineLimit(1)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundStyle(isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Search Results List

private struct SearchResultsList: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let results: [SearchResultItemDTO]
    let total: Int
    let isLoadingMore: Bool
    let hasMore: Bool
    let onResultClick: (SearchResultItemDTO) -> Void
    let onLoadMore: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                // 结果数量
                Text(String(format: String(localized: "search.resultsCount"), total))
                    .font(HeritageTypography.labelLarge)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                // 结果列表
                ForEach(results, id: \.id) { item in
                    SearchResultRow(
                        item: item,
                        onClick: { onResultClick(item) }
                    )
                    .padding(.horizontal, 16)
                }

                // 加载更多
                if isLoadingMore {
                    ProgressView()
                        .padding(16)
                } else if hasMore {
                    Button(action: onLoadMore) {
                        Text(String(localized: "search.loadMore"))
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.primary)
                    }
                    .padding(16)
                }

                // 底部间距
                Spacer()
                    .frame(height: 18)
            }
        }
    }
}

// MARK: - Search Result Row

private struct SearchResultRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let item: SearchResultItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 6) {
                // 类型和分类标签
                HStack(spacing: 8) {
                    SearchTypeBadge(text: localizedSearchResultType(item.type))

                    if let category = item.category, !category.isEmpty {
                        SearchTypeBadge(text: localizedArticleCategory(category))
                    }

                    if let kind = item.kind, !kind.isEmpty {
                        SearchTypeBadge(text: kind)
                    }
                }

                // 标题
                Text(item.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                // 摘要
                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(3)
                }

                // 高亮
                if let highlights = item.highlights, !highlights.isEmpty {
                    Text(highlights[0])
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.primary)
                        .lineLimit(2)
                }

                // 地区和年份
                HStack(spacing: 12) {
                    if let region = item.region, !region.isEmpty {
                        Text(region)
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }

                    if let year = item.publishedYear {
                        Text("\(year)年")
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Search Type Badge

private struct SearchTypeBadge: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let text: String

    var body: some View {
        Text(text)
            .font(HeritageTypography.labelMedium)
            .fontWeight(.semibold)
            .foregroundStyle(colorScheme.onPrimaryContainer)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(colorScheme.primaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Search Empty Content

private struct SearchEmptyContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            Text(String(localized: "search.emptyTitle"))
                .font(HeritageTypography.headlineSmall)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme.onSurface)

            Text(String(localized: "search.emptyMessage"))
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
        }
        .padding(32)
    }
}

// MARK: - Search Error Content

private struct SearchErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let error: AppError
    let onRetry: () -> Void
    let onClearError: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(error.localizedDescription)
                .font(HeritageTypography.bodyLarge)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            HStack(spacing: 8) {
                Button(action: onClearError) {
                    Text(String(localized: "nav.back"))
                        .font(HeritageTypography.labelLarge)
                }
                .buttonStyle(.bordered)

                Button(action: onRetry) {
                    Text(String(localized: "action.retry"))
                        .font(HeritageTypography.labelLarge)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(32)
    }
}

// MARK: - Search Filter Sheet

private struct SearchFilterSheet: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let uiState: SearchUiState
    let onToggleType: (SearchResultType) -> Void
    let onUpdateRegion: (String) -> Void
    let onUpdateCategory: (String) -> Void
    let onUpdateYear: (Int?) -> Void
    let onUpdateKind: (DirectoryItemKind?) -> Void
    let onUpdateHasImage: (Bool?) -> Void
    let onClearAll: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题
            Text(String(localized: "filter.title"))
                .font(HeritageTypography.titleLarge)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme.onSurface)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 18)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // 类型筛选
                    if let facets = uiState.facets, !facets.types.isEmpty {
                        FilterSection(
                            title: String(localized: "search.filterType"),
                            buckets: facets.types,
                            selectedKeys: Set(uiState.selectedTypes.map { $0.wireName }),
                            onToggle: { key in
                                if let type = SearchResultType.allCases.first(where: { $0.wireName == key }) {
                                    onToggleType(type)
                                }
                            }
                        )
                    }

                    // 分类筛选
                    if let facets = uiState.facets, !facets.categories.isEmpty {
                        FilterSection(
                            title: String(localized: "filter.category"),
                            buckets: facets.categories,
                            selectedKeys: uiState.categoryFilter.isEmpty ? [] : [uiState.categoryFilter],
                            onToggle: { key in
                                onUpdateCategory(uiState.categoryFilter == key ? "" : key)
                            }
                        )
                    }

                    // 地区筛选
                    if let facets = uiState.facets, !facets.regions.isEmpty {
                        FilterSection(
                            title: String(localized: "filter.region"),
                            buckets: facets.regions,
                            selectedKeys: uiState.regionFilter.isEmpty ? [] : [uiState.regionFilter],
                            onToggle: { key in
                                onUpdateRegion(uiState.regionFilter == key ? "" : key)
                            }
                        )
                    }

                    // 种类筛选
                    if let facets = uiState.facets, !facets.kinds.isEmpty {
                        FilterSection(
                            title: String(localized: "search.filterKind"),
                            buckets: facets.kinds,
                            selectedKeys: uiState.kindFilter != nil ? [uiState.kindFilter!.wireName] : [],
                            onToggle: { key in
                                let kind = DirectoryItemKind.allCases.first(where: { $0.wireName == key })
                                onUpdateKind(uiState.kindFilter == kind ? nil : kind)
                            }
                        )
                    }

                    // 年份筛选
                    if let facets = uiState.facets, !facets.years.isEmpty {
                        FilterSection(
                            title: String(localized: "filter.year"),
                            buckets: facets.years,
                            selectedKeys: uiState.yearFilter != nil ? ["\(uiState.yearFilter!)"] : [],
                            onToggle: { key in
                                let year = Int(key)
                                onUpdateYear(uiState.yearFilter == year ? nil : year)
                            }
                        )
                    }

                    // 按钮
                    HStack {
                        Button(action: onClearAll) {
                            Text(String(localized: "filter.clear"))
                                .font(HeritageTypography.labelLarge)
                                .foregroundStyle(colorScheme.primary)
                        }

                        Spacer()

                        Button(action: onDismiss) {
                            Text(String(localized: "filter.apply"))
                                .font(HeritageTypography.labelLarge)
                                .foregroundStyle(colorScheme.primary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(colorScheme.surfaceContainerLow)
    }
}

// MARK: - Filter Section

private struct FilterSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let title: String
    let buckets: [FacetBucketDTO]
    let selectedKeys: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(HeritageTypography.titleMedium)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme.onSurface)

            FlowLayout(spacing: 8) {
                ForEach(buckets, id: \.key) { bucket in
                    if let key = bucket.key {
                        Button(action: { onToggle(key) }) {
                            Text("\(key) (\(bucket.count))")
                                .font(HeritageTypography.labelMedium)
                                .foregroundStyle(selectedKeys.contains(key) ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(selectedKeys.contains(key) ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions

/// 获取本地化的搜索结果类型（String?版本）
private func localizedSearchResultType(_ type: String?) -> String {
    guard let key = ContentLabels.localizedSearchResultType(type) else { return type ?? "" }
    return String(localized: String.LocalizationValue(key))
}

/// 获取本地化的搜索结果类型（SearchResultType版本）
private func localizedSearchResultType(_ type: SearchResultType) -> String {
    String(localized: String.LocalizationValue(ContentLabels.searchResultTypeKey(type)))
}

/// 获取本地化的文章分类
private func localizedArticleCategory(_ category: String) -> String {
    guard let key = ContentLabels.localizedArticleCategory(category) else { return category }
    return String(localized: String.LocalizationValue(key))
}

/// 获取本地化的名录种类
private func localizedDirectoryKind(_ kind: DirectoryItemKind) -> String {
    String(localized: String.LocalizationValue(ContentLabels.directoryKindKey(kind)))
}

// MARK: - SearchResultType Extension

extension SearchResultType: CaseIterable {
    public static var allCases: [SearchResultType] {
        [.article, .directoryItem, .inheritor]
    }
}

#Preview {
    NavigationStack {
        SearchView(
            initialQuery: "",
            onBack: {},
            onArticleSelected: { _ in },
            onDirectoryItemSelected: { _ in },
            onInheritorSelected: { _ in }
        )
    }
    .heritageTheme()
}
