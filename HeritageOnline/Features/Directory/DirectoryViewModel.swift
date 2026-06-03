import SwiftUI
import Foundation

/// 名录页面 Tab 类型（名录列表 / 统计）
enum DirectoryPageTab: String, CaseIterable {
    case list
    case statistics

    var localizationKey: LocalizedStringKey {
        switch self {
        case .list: return "directory.tab.list"
        case .statistics: return "directory.tab.statistics"
        }
    }
}

/// 名录统计状态
@MainActor
@Observable
final class DirectoryStatisticsState {
    var isLoading: Bool = false
    var overview: DirectoryStatisticsOverviewDTO?
    var yearBreakdown: DirectoryStatisticDimensionDTO?
    var categoryBreakdown: DirectoryStatisticDimensionDTO?
    var regionBreakdown: DirectoryStatisticDimensionDTO?
    var error: AppError?
}

/// 名录页面状态
/// 对齐 Android DirectoryUiState
@MainActor
@Observable
final class DirectoryUiState {
    var selectedKind: DirectoryItemKind = .nationalProject
    var searchKeywords: String = ""
    var regionFilter: String = ""
    var categoryFilter: String = ""
    var yearFilter: String = ""
    var listTypeFilter: String = ""
    var selectedTab: DirectoryPageTab = .list
    var statisticsState = DirectoryStatisticsState()

    /// 文章列表
    var items: [DirectoryItemSummaryDTO] = []
    var currentPage: Int = 1
    var hasMore: Bool = true
    var isLoading: Bool = true
    var isLoadingMore: Bool = false
    var error: AppError?
    var appendError: AppError?

    /// 活跃筛选数量
    var activeFilterCount: Int {
        [regionFilter, categoryFilter, yearFilter, listTypeFilter].count { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }
}

/// 名录 ViewModel
/// 对齐 Android DirectoryViewModel
@MainActor
@Observable
final class DirectoryViewModel {
    let uiState = DirectoryUiState()
    private let repository: HeritageRepository
    private var searchTask: Task<Void, Never>?
    private var statisticsTask: Task<Void, Never>?

    /// 统计请求 ID，用于防止旧请求覆盖新数据
    private var statisticsRequestID: Int = 0

    /// 分页防重入：记录正在加载的页码
    private var loadingMorePage: Int?

    init(repository: HeritageRepository = DefaultHeritageRepository()) {
        self.repository = repository
    }

    // MARK: - 名录列表

    func loadItems() async {
        uiState.isLoading = true
        uiState.error = nil
        uiState.currentPage = 1
        loadingMorePage = nil

        let query = buildQuery(page: 1)

        do {
            let result = try await repository.directoryItems(query: query)
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
            let result = try await repository.directoryItems(query: query)
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
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadItems() }
            if uiState.selectedTab == .statistics {
                group.addTask { await self.loadStatistics() }
            }
        }
    }

    // MARK: - 统计

    func loadStatistics() async {
        statisticsTask?.cancel()
        uiState.statisticsState.isLoading = true
        uiState.statisticsState.error = nil

        let kind = uiState.selectedKind
        let requestID = statisticsRequestID + 1
        statisticsRequestID = requestID

        statisticsTask = Task {
            do {
                async let overview = repository.directoryStatisticsOverview(kind: kind)
                async let yearBD = repository.directoryStatisticsBreakdown(kind: kind, dimension: .publishedYear, limit: 50)
                async let categoryBD = repository.directoryStatisticsBreakdown(kind: kind, dimension: .category, limit: 12)
                async let regionBD = repository.directoryStatisticsBreakdown(kind: kind, dimension: .region, limit: 20)

                let (ov, year, category, region) = try await (overview, yearBD, categoryBD, regionBD)

                // 只有当 requestID 和 kind 都匹配时才写入 state
                guard requestID == statisticsRequestID, kind == uiState.selectedKind else { return }
                uiState.statisticsState.overview = ov
                uiState.statisticsState.yearBreakdown = year
                uiState.statisticsState.categoryBreakdown = category
                uiState.statisticsState.regionBreakdown = region
                uiState.statisticsState.isLoading = false
            } catch {
                guard requestID == statisticsRequestID, kind == uiState.selectedKind else { return }
                uiState.statisticsState.error = AppError.from(error)
                uiState.statisticsState.isLoading = false
            }
        }
        await statisticsTask?.value
    }

    // MARK: - 筛选操作

    func selectKind(_ kind: DirectoryItemKind) {
        guard uiState.selectedKind != kind else { return }
        uiState.selectedKind = kind
        Task {
            await loadItems()
            if uiState.selectedTab == .statistics {
                await loadStatistics()
            }
        }
    }

    func selectTab(_ tab: DirectoryPageTab) {
        guard uiState.selectedTab != tab else { return }
        uiState.selectedTab = tab
        if tab == .statistics && uiState.statisticsState.overview == nil {
            Task { await loadStatistics() }
        }
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

    func applyFilters(region: String, category: String, year: String, listType: String) {
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
        uiState.listTypeFilter = listType
        uiState.error = nil
        Task { await loadItems() }
    }

    func clearFilterField(_ field: DirectoryFilterField) {
        switch field {
        case .region: uiState.regionFilter = ""
        case .category: uiState.categoryFilter = ""
        case .year: uiState.yearFilter = ""
        case .listType: uiState.listTypeFilter = ""
        }
        Task { await loadItems() }
    }

    func clearAdvancedFilters() {
        uiState.regionFilter = ""
        uiState.categoryFilter = ""
        uiState.yearFilter = ""
        uiState.listTypeFilter = ""
        Task { await loadItems() }
    }

    // MARK: - 内部方法

    private func buildQuery(page: Int) -> DirectoryItemQuery {
        let trim: (String) -> String? = { $0.trimmingCharacters(in: .whitespaces).isEmpty ? nil : $0.trimmingCharacters(in: .whitespaces) }
        return DirectoryItemQuery(
            kind: uiState.selectedKind,
            page: page,
            pageSize: 20,
            keywords: trim(uiState.searchKeywords),
            region: trim(uiState.regionFilter),
            category: trim(uiState.categoryFilter),
            year: YearFilterValidator.parseInt(uiState.yearFilter),
            listType: trim(uiState.listTypeFilter)
        )
    }
}

/// 名录筛选字段枚举
enum DirectoryFilterField: String, CaseIterable {
    case region
    case category
    case year
    case listType

    var localizationKey: LocalizedStringKey {
        switch self {
        case .region: return "directory.filter.region"
        case .category: return "directory.filter.category"
        case .year: return "directory.filter.year"
        case .listType: return "directory.filter.listType"
        }
    }
}

/// DirectoryItemKind CaseIterable 扩展
extension DirectoryItemKind: CaseIterable {
    public static var allCases: [DirectoryItemKind] = [
        .nationalProject, .culturalEcoZone, .productiveProtectionBase,
        .unescoEntry, .chinaUnescoEntry, .contractingState
    ]

    /// 本地化显示名称
    var displayName: String {
        let key = ContentLabels.localizedDirectoryKind(self.wireName) ?? self.wireName
        return String(localized: String.LocalizationValue(key))
    }
}
