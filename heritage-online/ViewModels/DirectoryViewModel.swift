import Foundation
import Observation

@MainActor
@Observable
class DirectoryViewModel {
    var selectedKind: DirectoryItemKind = .nationalProject
    var searchKeywords: String = ""
    var regionFilter: String = ""
    var categoryFilter: String = ""
    var yearFilter: String = ""
    var listTypeFilter: String = ""

    var items: [DirectoryItemSummaryDto] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String?
    var hasMore: Bool = true
    private var currentPage: Int = 1

    var statistics: DirectoryStatisticsOverviewDto?
    var isLoadingStatistics: Bool = false

    private let repository: HeritageRepositoryProtocol

    var activeFilterCount: Int {
        [regionFilter, categoryFilter, yearFilter, listTypeFilter].filter { !$0.isEmpty }.count
    }

    init(repository: HeritageRepositoryProtocol = HeritageRepository()) {
        self.repository = repository
    }

    func loadItems() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMore = true

        let query = DirectoryItemQuery(
            kind: selectedKind,
            page: 1,
            pageSize: 20,
            keywords: searchKeywords.isEmpty ? nil : searchKeywords,
            region: regionFilter.isEmpty ? nil : regionFilter,
            category: categoryFilter.isEmpty ? nil : categoryFilter,
            year: Int(yearFilter),
            listType: listTypeFilter.isEmpty ? nil : listTypeFilter
        )

        do {
            let result = try await repository.directoryItems(query: query)
            items = result.items
            hasMore = result.hasMore
            currentPage = 1
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadMoreItems() async {
        guard !isLoadingMore, hasMore else { return }
        isLoadingMore = true

        let nextPage = currentPage + 1
        let query = DirectoryItemQuery(
            kind: selectedKind,
            page: nextPage,
            pageSize: 20,
            keywords: searchKeywords.isEmpty ? nil : searchKeywords,
            region: regionFilter.isEmpty ? nil : regionFilter,
            category: categoryFilter.isEmpty ? nil : categoryFilter,
            year: Int(yearFilter),
            listType: listTypeFilter.isEmpty ? nil : listTypeFilter
        )

        do {
            let result = try await repository.directoryItems(query: query)
            items.append(contentsOf: result.items)
            hasMore = result.hasMore
            currentPage = nextPage
            isLoadingMore = false
        } catch {
            isLoadingMore = false
        }
    }

    func loadStatistics() async {
        isLoadingStatistics = true
        do {
            statistics = try await repository.directoryStatisticsOverview(kind: selectedKind)
            isLoadingStatistics = false
        } catch {
            isLoadingStatistics = false
        }
    }

    func refresh() async {
        await loadItems()
        await loadStatistics()
    }
}
