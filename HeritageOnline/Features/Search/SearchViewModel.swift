import Foundation
import SwiftUI

/// 搜索页 ViewModel
/// 对齐 Android SearchViewModel
@MainActor
@Observable
final class SearchViewModel {
    var uiState = SearchUiState()

    private let repository: HeritageRepository
    private var searchTask: Task<Void, Never>?
    private var suggestionTask: Task<Void, Never>?

    private let searchDebounceMs: UInt64 = 350
    private let suggestionDebounceMs: UInt64 = 200
    private let pageSize = 20

    init(repository: HeritageRepository = DefaultHeritageRepository()) {
        self.repository = repository
    }

    /// 更新查询文本
    func updateQuery(_ query: String) {
        uiState = uiState.withQuery(query)

        // 防抖加载建议
        suggestionTask?.cancel()
        suggestionTask = Task {
            try? await Task.sleep(nanoseconds: suggestionDebounceMs * 1_000_000)
            guard !Task.isCancelled else { return }

            let currentQuery = uiState.query.trimmingCharacters(in: .whitespaces)
            if !currentQuery.isEmpty && uiState.results.isEmpty {
                await loadSuggestions(prefix: currentQuery)
            } else {
                uiState = uiState.withSuggestions([])
            }
        }
    }

    /// 执行搜索
    func search() {
        let query = uiState.query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return }

        searchTask?.cancel()
        suggestionTask?.cancel()

        uiState = uiState.searching()

        searchTask = Task {
            do {
                let response = try await performSearch(query: query, page: 1)
                guard !Task.isCancelled else { return }
                uiState = uiState.withResults(response)
            } catch {
                guard !Task.isCancelled else { return }
                uiState = uiState.withError(AppError.from(error))
            }
        }
    }

    /// 加载更多
    func loadMore() {
        guard !uiState.isLoadingMore && uiState.hasMore && !uiState.query.isEmpty else { return }

        let nextPage = uiState.page + 1
        uiState = uiState.loadingMore()

        Task {
            do {
                let response = try await performSearch(query: uiState.query.trimmingCharacters(in: .whitespaces), page: nextPage)
                guard !Task.isCancelled else { return }
                uiState = uiState.withMoreResults(response)
            } catch {
                guard !Task.isCancelled else { return }
                uiState = uiState.withError(AppError.from(error))
            }
        }
    }

    /// 选择建议
    func selectSuggestion(_ text: String) {
        uiState = uiState.withQuery(text).withSuggestions([])
        search()
    }

    /// 切换类型筛选
    func toggleType(_ type: SearchResultType) {
        var newTypes = uiState.selectedTypes
        if newTypes.contains(type) {
            newTypes.remove(type)
        } else {
            newTypes.insert(type)
        }
        uiState = uiState.withFilters(selectedTypes: newTypes)
        search()
    }

    /// 更新地区筛选
    func updateRegionFilter(_ region: String) {
        uiState = uiState.withFilters(regionFilter: region)
        search()
    }

    /// 更新分类筛选
    func updateCategoryFilter(_ category: String) {
        uiState = uiState.withFilters(categoryFilter: category)
        search()
    }

    /// 更新年份筛选
    func updateYearFilter(_ year: Int?) {
        uiState = uiState.withFilters(yearFilter: year)
        search()
    }

    /// 更新种类筛选
    func updateKindFilter(_ kind: DirectoryItemKind?) {
        uiState = uiState.withFilters(kindFilter: kind)
        search()
    }

    /// 更新是否有图筛选
    func updateHasImageFilter(_ hasImage: Bool?) {
        uiState = uiState.withFilters(hasImageFilter: hasImage)
        search()
    }

    /// 清除筛选条件
    func clearFilters() {
        uiState = uiState.clearingFilters()
        search()
    }

    /// 清除错误
    func clearError() {
        uiState = uiState.clearingError()
    }

    // MARK: - Private Methods

    /// 加载搜索建议
    private func loadSuggestions(prefix: String) async {
        uiState = uiState.withSuggestionsLoading(true)

        do {
            let suggestions = try await repository.searchSuggestions(prefix: prefix, limit: 10)
            guard !Task.isCancelled else { return }
            uiState = uiState.withSuggestions(suggestions)
        } catch {
            guard !Task.isCancelled else { return }
            // 建议加载失败不显示错误，只清除加载状态
            uiState = uiState.withSuggestionsLoading(false)
        }
    }

    /// 执行搜索请求
    private func performSearch(query: String, page: Int) async throws -> SearchV2ResponseDTO {
        let searchQuery = SearchV2Query(
            keywords: query,
            types: uiState.selectedTypes,
            page: page,
            pageSize: pageSize,
            region: uiState.regionFilter.isEmpty ? nil : uiState.regionFilter,
            category: uiState.categoryFilter.isEmpty ? nil : uiState.categoryFilter,
            year: uiState.yearFilter,
            kind: uiState.kindFilter,
            hasImage: uiState.hasImageFilter
        )
        return try await repository.searchV2(query: searchQuery)
    }
}
