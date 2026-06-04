import Foundation

/// 合集详情页 ViewModel
/// 对齐 Android CollectionViewModel
@MainActor
@Observable
final class CollectionDetailViewModel {
    var isLoading = true
    var collection: CollectionDTO?
    var error: AppError?

    private let id: String?
    private let type: String?
    private let topicKey: String?
    private let repository: HeritageRepository

    /// 按 id 初始化（精选合集 / 固定合集）
    init(id: String, repository: HeritageRepository = DefaultHeritageRepository()) {
        self.id = id
        self.type = nil
        self.topicKey = nil
        self.repository = repository
    }

    /// 按 type + key 初始化（主题合集）
    init(type: String, key: String, repository: HeritageRepository = DefaultHeritageRepository()) {
        self.id = nil
        self.type = type
        self.topicKey = key
        self.repository = repository
    }

    /// 加载合集详情
    func loadCollection() {
        isLoading = true
        error = nil

        Task {
            do {
                let data: CollectionDTO
                if let id, !id.isEmpty {
                    data = try await repository.collection(id: id)
                } else if let type, !type.isEmpty, let topicKey, !topicKey.isEmpty {
                    data = try await repository.topicCollection(type: type, key: topicKey)
                } else {
                    throw AppError.unknown("Missing collection identifier")
                }
                collection = data
                isLoading = false
            } catch {
                self.error = AppError.from(error)
                isLoading = false
            }
        }
    }
}
