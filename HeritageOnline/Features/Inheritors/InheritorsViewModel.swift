import SwiftUI
import Foundation

/// 传承人页面状态
/// 对齐 Android InheritorsUiState
@Observable
final class InheritorsUiState {
    var searchKeywords: String = ""
    var regionFilter: String = ""
    var categoryFilter: String = ""
    var yearFilter: String = ""
    var genderFilter: String = ""

    var items: [InheritorSummaryDTO] = []
    var currentPage: Int = 1
    var hasMore: Bool = true
    var isLoading: Bool = true
    var isLoadingMore: Bool = false
    var error: AppError?
    var appendError: AppError?

    var activeFilterCount: Int {
        [regionFilter, categoryFilter, yearFilter, genderFilter].count { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

/// 传承人 ViewModel
/// 对齐 Android InheritorsViewModel
@Observable
final class InheritorsViewModel {
    let uiState = InheritorsUiState()
    private let repository: HeritageRepository
    private var searchTask: Task<Void, Never>?

    init(repository: HeritageRepository = DefaultHeritageRepository()) {
        self.repository = repository
    }

    func loadItems() async {
        uiState.isLoading = true
        uiState.error = nil
        uiState.currentPage = 1

        let query = buildQuery(page: 1)

        do {
            let result = try await repository.inheritors(query: query)
            uiState.items = result.items
            uiState.hasMore = result.hasMore
            uiState.isLoading = false
        } catch {
            uiState.error = AppError.from(error)
            uiState.isLoading = false
        }
    }

    func loadMore() async {
        guard !uiState.isLoadingMore, uiState.hasMore else { return }
        uiState.isLoadingMore = true
        uiState.appendError = nil

        let nextPage = uiState.currentPage + 1
        let query = buildQuery(page: nextPage)

        do {
            let result = try await repository.inheritors(query: query)
            uiState.items.append(contentsOf: result.items)
            uiState.hasMore = result.hasMore
            uiState.currentPage = nextPage
            uiState.isLoadingMore = false
        } catch {
            uiState.appendError = AppError.from(error)
            uiState.isLoadingMore = false
        }
    }

    func refresh() async {
        await loadItems()
    }

    func updateSearchKeywords(_ keywords: String) {
        uiState.searchKeywords = keywords
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await self.loadItems()
        }
    }

    func applyFilters(region: String, category: String, year: String, gender: String) {
        uiState.regionFilter = region
        uiState.categoryFilter = category
        uiState.yearFilter = year
        uiState.genderFilter = gender
        Task { await loadItems() }
    }

    func clearFilterField(_ field: InheritorFilterField) {
        switch field {
        case .region: uiState.regionFilter = ""
        case .category: uiState.categoryFilter = ""
        case .year: uiState.yearFilter = ""
        case .gender: uiState.genderFilter = ""
        }
        Task { await loadItems() }
    }

    func clearAdvancedFilters() {
        uiState.regionFilter = ""
        uiState.categoryFilter = ""
        uiState.yearFilter = ""
        uiState.genderFilter = ""
        Task { await loadItems() }
    }

    private func buildQuery(page: Int) -> InheritorQuery {
        let trim: (String) -> String? = { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0.trimmingCharacters(in: .whitespaces) }
        return InheritorQuery(
            page: page,
            pageSize: 20,
            keywords: trim(uiState.searchKeywords),
            region: trim(uiState.regionFilter),
            category: trim(uiState.categoryFilter),
            year: Int(uiState.yearFilter.trimmingCharacters(in: .whitespaces)),
            gender: trim(uiState.genderFilter)
        )
    }
}

/// 传承人筛选字段枚举
enum InheritorFilterField: String, CaseIterable {
    case region
    case category
    case year
    case gender

    var localizationKey: LocalizedStringKey {
        switch self {
        case .region: return "inheritors.filter.region"
        case .category: return "inheritors.filter.category"
        case .year: return "inheritors.filter.year"
        case .gender: return "inheritors.filter.gender"
        }
    }
}
