import Foundation

/// 地区详情页 ViewModel
/// 对齐 Android RegionDetailViewModel
@MainActor
@Observable
final class RegionDetailViewModel {
    var isLoading = true
    var detail: RegionAtlasDetailDTO?
    var error: AppError?

    private let region: String
    private let repository: HeritageRepository

    init(region: String, repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.region = region
        self.repository = repository
    }

    /// 加载地区详情
    func loadDetail() {
        isLoading = true
        error = nil

        Task {
            do {
                let data = try await repository.regionAtlasDetail(region: region, limit: 6)
                detail = data
                isLoading = false
            } catch {
                self.error = AppError.from(error)
                isLoading = false
            }
        }
    }
}
