import Foundation

/// 数据故事首页状态
@MainActor
@Observable
final class StoriesIndexUiState {
    var isLoading = true
    var error: AppError?
    var regions: [TaxonomyTopicDTO] = []
    var categories: [TaxonomyTopicDTO] = []
    var years: [TimelineYearBucketDTO] = []
}

/// 数据故事首页 ViewModel
@MainActor
@Observable
final class StoriesIndexViewModel {
    let uiState = StoriesIndexUiState()
    private let repository: HeritageRepository

    init(repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.repository = repository
    }

    func loadAll() {
        uiState.isLoading = true
        uiState.error = nil

        Task {
            do {
                async let regionsResult = repository.taxonomyRegions(limit: 12, sort: .total)
                async let categoriesResult = repository.taxonomyCategories(limit: 12)
                async let yearsResult = repository.timelineYears()

                let (regions, categories, years) = try await (regionsResult, categoriesResult, yearsResult)

                uiState.regions = regions.items
                uiState.categories = categories.items
                uiState.years = Array(years.prefix(10))
                uiState.isLoading = false
            } catch {
                uiState.error = AppError.from(error)
                uiState.isLoading = false
            }
        }
    }
}
