import Foundation

/// 主题库详情页面状态
@MainActor
@Observable
final class TaxonomyDetailUiState {
    var isLoading = true
    var error: AppError?
    var categoryDetail: TaxonomyCategoryDetailDTO?
    var regionDetail: TaxonomyRegionDetailDTO?
}

/// 主题库详情 ViewModel
@MainActor
@Observable
final class TaxonomyDetailViewModel {
    let uiState = TaxonomyDetailUiState()
    private let type: String
    private let key: String
    private let repository: HeritageRepository

    init(type: String, key: String, repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.type = type
        self.key = key
        self.repository = repository
    }

    func loadDetail() {
        uiState.isLoading = true
        uiState.error = nil

        Task {
            do {
                switch type {
                case "category":
                    let detail = try await repository.taxonomyCategoryDetail(category: key, limit: 6)
                    uiState.categoryDetail = detail
                case "region":
                    let detail = try await repository.taxonomyRegionDetail(region: key, limit: 6)
                    uiState.regionDetail = detail
                default:
                    uiState.error = .notFound
                }
                uiState.isLoading = false
            } catch {
                uiState.error = AppError.from(error)
                uiState.isLoading = false
            }
        }
    }

    /// 获取主题标题
    var title: String {
        uiState.categoryDetail?.topic?.title ?? uiState.regionDetail?.topic?.title ?? key
    }

    /// 获取主题类型
    var topicType: String { type }
    var topicKey: String { key }
}
