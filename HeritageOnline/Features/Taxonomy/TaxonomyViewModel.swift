import Foundation

/// 主题库页面状态
@MainActor
@Observable
final class TaxonomyUiState {
    var isLoading = true
    var error: AppError?
    var categories: [TaxonomyTopicDTO] = []
    var regions: [TaxonomyTopicDTO] = []
    var kinds: [TaxonomyKindDTO] = []
}

/// 主题库 ViewModel
@MainActor
@Observable
final class TaxonomyViewModel {
    let uiState = TaxonomyUiState()
    private let repository: HeritageRepository

    init(repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.repository = repository
    }

    func loadAll() {
        uiState.isLoading = true
        uiState.error = nil

        Task {
            do {
                async let categoriesResult = repository.taxonomyCategories(limit: 50)
                async let regionsResult = repository.taxonomyRegions(limit: 50, sort: .total)
                async let kindsResult = repository.taxonomyKinds()

                let (categories, regions, kinds) = try await (categoriesResult, regionsResult, kindsResult)

                uiState.categories = categories.items
                uiState.regions = regions.items
                uiState.kinds = kinds.items
                uiState.isLoading = false
            } catch {
                uiState.error = AppError.from(error)
                uiState.isLoading = false
            }
        }
    }
}
