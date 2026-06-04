import Foundation

/// 深度探索页 ViewModel
/// 对齐 Android DiscoveryDeepDiveViewModel
@MainActor
@Observable
final class DiscoveryDeepDiveViewModel {
    var seed: DiscoveryItemDTO?
    var related: [DiscoveryItemDTO] = []
    var generatedAt: String?
    var isLoading = false
    var error: AppError?

    private let seedType: SearchResultType
    private let seedId: String
    private let repository: HeritageRepository

    init(
        seedType: SearchResultType,
        seedId: String,
        repository: HeritageRepository = AppDependencies.shared.heritageRepository
    ) {
        self.seedType = seedType
        self.seedId = seedId
        self.repository = repository
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            let query = DiscoveryDeepDiveQuery(
                seedType: seedType,
                seedId: seedId,
                limit: 10
            )
            let result = try await repository.discoveryDeepDive(query: query)
            seed = result.seed
            related = result.related
            generatedAt = result.generatedAt
        } catch {
            self.error = AppError.from(error)
        }

        isLoading = false
    }

    func retry() async {
        await load()
    }
}
