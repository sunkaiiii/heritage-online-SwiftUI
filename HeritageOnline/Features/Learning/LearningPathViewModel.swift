import Foundation

/// 学习路径详情页 ViewModel
/// 对齐 Android LearningPathViewModel
@MainActor
@Observable
final class LearningPathViewModel {
    var isLoading = true
    var path: LearningPathDetailDTO?
    var error: AppError?

    private let id: String
    private let repository: HeritageRepository

    init(id: String, repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.id = id
        self.repository = repository
    }

    /// 加载学习路径详情
    func loadPath() {
        isLoading = true
        error = nil

        Task {
            do {
                let data = try await repository.learningPathDetail(id: id, limit: 6)
                path = data
                isLoading = false
            } catch {
                self.error = AppError.from(error)
                isLoading = false
            }
        }
    }
}
