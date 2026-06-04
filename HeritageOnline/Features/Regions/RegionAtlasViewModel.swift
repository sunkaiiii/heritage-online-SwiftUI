import Foundation

/// 地区图谱首页 ViewModel
/// 对齐 Android RegionViewModel
@MainActor
@Observable
final class RegionAtlasViewModel {
    var isLoading = true
    var atlas: RegionAtlasDTO?
    var error: AppError?

    private let repository: HeritageRepository

    init(repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.repository = repository
    }

    /// 加载地区图谱
    func loadAtlas() {
        isLoading = true
        error = nil

        Task {
            do {
                let data = try await repository.regionAtlas()
                atlas = data
                isLoading = false
            } catch {
                self.error = AppError.from(error)
                isLoading = false
            }
        }
    }
}
