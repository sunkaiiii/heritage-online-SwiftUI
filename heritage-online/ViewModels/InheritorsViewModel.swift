import Foundation
import Observation

@Observable
class InheritorsViewModel {
    var searchKeywords: String = ""
    var regionFilter: String = ""
    var categoryFilter: String = ""
    var yearFilter: String = ""
    var genderFilter: String = ""

    var items: [InheritorSummaryDto] = []
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String?
    var hasMore: Bool = true
    private var currentPage: Int = 1

    private let repository: HeritageRepositoryProtocol

    var activeFilterCount: Int {
        [regionFilter, categoryFilter, yearFilter, genderFilter].filter { !$0.isEmpty }.count
    }

    init(repository: HeritageRepositoryProtocol = HeritageRepository()) {
        self.repository = repository
    }

    func loadItems() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMore = true

        let query = InheritorQuery(
            page: 1,
            pageSize: 20,
            keywords: searchKeywords.isEmpty ? nil : searchKeywords,
            region: regionFilter.isEmpty ? nil : regionFilter,
            category: categoryFilter.isEmpty ? nil : categoryFilter,
            year: Int(yearFilter),
            gender: genderFilter.isEmpty ? nil : genderFilter
        )

        do {
            let result = try await repository.inheritors(query: query)
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
        let query = InheritorQuery(
            page: nextPage,
            pageSize: 20,
            keywords: searchKeywords.isEmpty ? nil : searchKeywords,
            region: regionFilter.isEmpty ? nil : regionFilter,
            category: categoryFilter.isEmpty ? nil : categoryFilter,
            year: Int(yearFilter),
            gender: genderFilter.isEmpty ? nil : genderFilter
        )

        do {
            let result = try await repository.inheritors(query: query)
            items.append(contentsOf: result.items)
            hasMore = result.hasMore
            currentPage = nextPage
            isLoadingMore = false
        } catch {
            isLoadingMore = false
        }
    }

    func refresh() async {
        await loadItems()
    }
}
