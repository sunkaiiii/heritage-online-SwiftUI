import SwiftUI
import Foundation

/// 传承人页面状态
/// 对齐 Android InheritorsUiState
@MainActor
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
@MainActor
@Observable
final class InheritorsViewModel {
    let uiState = InheritorsUiState()
    private let repository: HeritageRepository
    private var searchTask: Task<Void, Never>?

    /// 分页防重入：记录正在加载的页码
    private var loadingMorePage: Int?

    init(repository: HeritageRepository = DefaultHeritageRepository()) {
        self.repository = repository
    }

    func loadItems() async {
        uiState.isLoading = true
        uiState.error = nil
        uiState.currentPage = 1
        loadingMorePage = nil

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
        let nextPage = uiState.currentPage + 1

        // 页级别防重入
        guard !uiState.isLoadingMore, uiState.hasMore, loadingMorePage != nextPage else { return }

        uiState.isLoadingMore = true
        uiState.appendError = nil
        loadingMorePage = nextPage

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
        loadingMorePage = nil
    }

    func refresh() async {
        await loadItems()
    }

    func updateSearchKeywords(_ keywords: String) {
        uiState.searchKeywords = keywords
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await self.loadItems()
        }
    }

    func applyFilters(region: String, category: String, year: String, gender: String) {
        let trimmedYear = year.trimmingCharacters(in: .whitespaces)
        // 非空时校验必须为 4 位数字
        if !trimmedYear.isEmpty {
            guard YearFilterValidator.isValidYear(trimmedYear) else {
                uiState.error = .validationError(String(localized: "filter.invalidYear"))
                return
            }
        }
        uiState.regionFilter = region
        uiState.categoryFilter = category
        uiState.yearFilter = year
        uiState.genderFilter = gender
        uiState.error = nil
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
            year: YearFilterValidator.parseInt(uiState.yearFilter),
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
