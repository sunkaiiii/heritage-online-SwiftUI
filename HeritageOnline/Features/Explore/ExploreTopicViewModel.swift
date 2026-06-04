import Foundation

/// 探索主题详情页 ViewModel
/// 对齐 Android ExploreTopicViewModel
@MainActor
@Observable
final class ExploreTopicViewModel {
    var isLoading = true
    var topic: ExploreTopicV2DTO?
    var error: AppError?

    private let type: String
    private let key: String
    private let repository: HeritageRepository

    init(type: String, key: String, repository: HeritageRepository = DefaultHeritageRepository()) {
        self.type = type
        self.key = key
        self.repository = repository
    }

    /// 加载主题详情
    func loadTopic() {
        isLoading = true
        error = nil

        Task {
            do {
                let data = try await repository.exploreTopic(type: type, key: key, limit: 6)
                topic = data
                isLoading = false
            } catch {
                self.error = AppError.from(error)
                isLoading = false
            }
        }
    }
}
