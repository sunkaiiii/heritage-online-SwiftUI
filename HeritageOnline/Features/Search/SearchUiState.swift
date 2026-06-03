import Foundation

/// 搜索页 UI 状态
/// 对齐 Android SearchUiState
struct SearchUiState {
    let query: String
    let isSearching: Bool
    let results: [SearchResultItemDTO]
    let page: Int
    let hasMore: Bool
    let total: Int
    let facets: SearchFacetsDto?
    let selectedTypes: Set<SearchResultType>
    let regionFilter: String
    let categoryFilter: String
    let yearFilter: Int?
    let kindFilter: DirectoryItemKind?
    let hasImageFilter: Bool?
    let suggestions: [SearchSuggestionDTO]
    let isLoadingSuggestions: Bool
    let isLoadingMore: Bool
    let error: AppError?

    init(
        query: String = "",
        isSearching: Bool = false,
        results: [SearchResultItemDTO] = [],
        page: Int = 1,
        hasMore: Bool = false,
        total: Int = 0,
        facets: SearchFacetsDto? = nil,
        selectedTypes: Set<SearchResultType> = [],
        regionFilter: String = "",
        categoryFilter: String = "",
        yearFilter: Int? = nil,
        kindFilter: DirectoryItemKind? = nil,
        hasImageFilter: Bool? = nil,
        suggestions: [SearchSuggestionDTO] = [],
        isLoadingSuggestions: Bool = false,
        isLoadingMore: Bool = false,
        error: AppError? = nil
    ) {
        self.query = query
        self.isSearching = isSearching
        self.results = results
        self.page = page
        self.hasMore = hasMore
        self.total = total
        self.facets = facets
        self.selectedTypes = selectedTypes
        self.regionFilter = regionFilter
        self.categoryFilter = categoryFilter
        self.yearFilter = yearFilter
        self.kindFilter = kindFilter
        self.hasImageFilter = hasImageFilter
        self.suggestions = suggestions
        self.isLoadingSuggestions = isLoadingSuggestions
        self.isLoadingMore = isLoadingMore
        self.error = error
    }

    /// 是否有活跃的筛选条件
    var hasActiveFilters: Bool {
        !selectedTypes.isEmpty ||
        !regionFilter.isEmpty ||
        !categoryFilter.isEmpty ||
        yearFilter != nil ||
        kindFilter != nil ||
        hasImageFilter != nil
    }

    /// 活跃筛选条件数量
    var activeFilterCount: Int {
        var count = 0
        if !selectedTypes.isEmpty { count += 1 }
        if !regionFilter.isEmpty { count += 1 }
        if !categoryFilter.isEmpty { count += 1 }
        if yearFilter != nil { count += 1 }
        if kindFilter != nil { count += 1 }
        if hasImageFilter != nil { count += 1 }
        return count
    }

    /// 创建查询变更状态
    func withQuery(_ newQuery: String) -> SearchUiState {
        SearchUiState(
            query: newQuery,
            isSearching: isSearching,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: isLoadingMore,
            error: error
        )
    }

    /// 创建搜索中状态
    func searching() -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: true,
            results: [],
            page: 1,
            hasMore: false,
            total: 0,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: [],
            isLoadingSuggestions: false,
            isLoadingMore: false,
            error: nil
        )
    }

    /// 创建搜索成功状态
    func withResults(_ response: SearchV2ResponseDTO) -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: false,
            results: response.items,
            page: 1,
            hasMore: response.hasMore,
            total: response.total,
            facets: SearchFacetsDto.from(response.facets),
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: [],
            isLoadingSuggestions: false,
            isLoadingMore: false,
            error: nil
        )
    }

    /// 创建加载更多成功状态
    func withMoreResults(_ response: SearchV2ResponseDTO) -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: false,
            results: results + response.items,
            page: page + 1,
            hasMore: response.hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: false,
            error: nil
        )
    }

    /// 创建加载更多中状态
    func loadingMore() -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: false,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: true,
            error: nil
        )
    }

    /// 创建错误状态
    func withError(_ error: AppError) -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: false,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: false,
            error: error
        )
    }

    /// 清除错误状态
    func clearingError() -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: isSearching,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: isLoadingMore,
            error: nil
        )
    }

    /// 创建建议状态
    func withSuggestions(_ suggestions: [SearchSuggestionDTO]) -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: isSearching,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: false,
            isLoadingMore: isLoadingMore,
            error: error
        )
    }

    /// 设置建议加载状态
    func withSuggestionsLoading(_ loading: Bool) -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: isSearching,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes,
            regionFilter: regionFilter,
            categoryFilter: categoryFilter,
            yearFilter: yearFilter,
            kindFilter: kindFilter,
            hasImageFilter: hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: loading,
            isLoadingMore: isLoadingMore,
            error: error
        )
    }

    /// 创建筛选条件变更状态
    func withFilters(
        selectedTypes: Set<SearchResultType>? = nil,
        regionFilter: String? = nil,
        categoryFilter: String? = nil,
        yearFilter: Int?? = nil,
        kindFilter: DirectoryItemKind?? = nil,
        hasImageFilter: Bool?? = nil
    ) -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: isSearching,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: selectedTypes ?? self.selectedTypes,
            regionFilter: regionFilter ?? self.regionFilter,
            categoryFilter: categoryFilter ?? self.categoryFilter,
            yearFilter: yearFilter ?? self.yearFilter,
            kindFilter: kindFilter ?? self.kindFilter,
            hasImageFilter: hasImageFilter ?? self.hasImageFilter,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: isLoadingMore,
            error: error
        )
    }

    /// 清除筛选条件
    func clearingFilters() -> SearchUiState {
        SearchUiState(
            query: query,
            isSearching: isSearching,
            results: results,
            page: page,
            hasMore: hasMore,
            total: total,
            facets: facets,
            selectedTypes: [],
            regionFilter: "",
            categoryFilter: "",
            yearFilter: nil,
            kindFilter: nil,
            hasImageFilter: nil,
            suggestions: suggestions,
            isLoadingSuggestions: isLoadingSuggestions,
            isLoadingMore: isLoadingMore,
            error: error
        )
    }
}

/// 搜索分面 DTO
struct SearchFacetsDto {
    let types: [FacetBucketDTO]
    let categories: [FacetBucketDTO]
    let regions: [FacetBucketDTO]
    let kinds: [FacetBucketDTO]
    let years: [FacetBucketDTO]

    init(
        types: [FacetBucketDTO] = [],
        categories: [FacetBucketDTO] = [],
        regions: [FacetBucketDTO] = [],
        kinds: [FacetBucketDTO] = [],
        years: [FacetBucketDTO] = []
    ) {
        self.types = types
        self.categories = categories
        self.regions = regions
        self.kinds = kinds
        self.years = years
    }

    /// 从 SearchFacetsDTO 转换
    static func from(_ facets: SearchFacetsDTO?) -> SearchFacetsDto? {
        guard let facets = facets else { return nil }
        return SearchFacetsDto(
            types: facets.types ?? [],
            categories: facets.categories ?? [],
            regions: facets.regions ?? [],
            kinds: facets.kinds ?? [],
            years: facets.years ?? []
        )
    }
}
