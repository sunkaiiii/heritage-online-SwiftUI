import SwiftUI
import Foundation

/// 传承人详情页面状态
@MainActor
@Observable
final class InheritorDetailUiState {
    var isLoading: Bool = true
    var item: InheritorDetailDTO?
    var error: AppError?
    var isFavorite: Bool = false
    var isContentStale: Bool = false

    // 探索区状态
    var digest: ContentDigestDTO?
    var digestLoading: Bool = false
    var digestError: AppError?

    var context: DetailContextDTO?
    var contextLoading: Bool = false
    var contextError: AppError?

    var blendedRecommendations: [BlendedRecommendationItemDTO] = []
    var blendedLoading: Bool = false
}

/// 传承人详情 ViewModel
@MainActor
@Observable
final class InheritorDetailViewModel {
    let uiState = InheritorDetailUiState()
    private let repository: HeritageRepository
    private let savedRepository: SavedContentRepository
    private let lookup: InheritorDetailLookup
    private var currentSnapshot: SavedContent?

    /// 请求 ID，用于防止旧请求覆盖新数据
    private var requestId: UUID = UUID()

    /// 运行中的附加区块 task
    private var contextTask: Task<Void, Never>?
    private var digestTask: Task<Void, Never>?
    private var blendedTask: Task<Void, Never>?

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil,
        repository: HeritageRepository = AppDependencies.shared.heritageRepository,
        savedRepository: SavedContentRepository = DefaultSavedContentRepository.shared
    ) {
        self.repository = repository
        self.savedRepository = savedRepository
        self.lookup = InheritorDetailLookup(
            inheritorId: inheritorId,
            sourceId: sourceId
        )
    }

    func refresh() async {
        let id = UUID()
        requestId = id

        contextTask?.cancel()
        digestTask?.cancel()
        blendedTask?.cancel()

        uiState.isLoading = uiState.item == nil
        uiState.error = nil

        do {
            let item = try await repository.inheritor(lookup: lookup)
            guard requestId == id else { return }

            uiState.item = item
            uiState.isLoading = false
            uiState.isContentStale = false

            recordViewedIfNew(item)
            if let key = currentSnapshot?.contentKey {
                uiState.isFavorite = await savedRepository.isFavorite(key)
            }

            if let itemId = item.id {
                loadContext(itemId: itemId, requestId: id)
                loadDigest(itemId: itemId, requestId: id)
                loadBlended(itemId: itemId, requestId: id)
            }
        } catch {
            guard requestId == id else { return }
            if uiState.item != nil {
                uiState.isContentStale = true
            } else {
                uiState.error = AppError.from(error)
            }
            uiState.isLoading = false
        }
    }

    func toggleFavorite() async {
        guard let snapshot = currentSnapshot else { return }
        await savedRepository.toggleFavorite(snapshot)
        uiState.isFavorite = await savedRepository.isFavorite(snapshot.contentKey)
    }

    private func recordViewedIfNew(_ item: InheritorDetailDTO) {
        let newSnapshot = SavedContent.fromInheritor(item)
        if currentSnapshot?.contentKey != newSnapshot.contentKey || currentSnapshot?.title != newSnapshot.title {
            currentSnapshot = newSnapshot
            Task { await savedRepository.recordViewed(newSnapshot) }
        }
    }

    // MARK: - 探索区加载

    func retryContext() {
        if let itemId = uiState.item?.id {
            loadContext(itemId: itemId, requestId: requestId)
        }
    }

    func retryDigest() {
        if let itemId = uiState.item?.id {
            loadDigest(itemId: itemId, requestId: requestId)
        }
    }

    private func loadContext(itemId: String, requestId: UUID) {
        uiState.contextLoading = true
        uiState.contextError = nil

        contextTask = Task {
            do {
                let context = try await repository.inheritorContext(id: itemId)
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.context = context
                uiState.contextLoading = false
            } catch {
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.contextError = AppError.from(error)
                uiState.contextLoading = false
            }
        }
    }

    private func loadDigest(itemId: String, requestId: UUID) {
        uiState.digestLoading = true
        uiState.digestError = nil

        digestTask = Task {
            do {
                let digest = try await repository.inheritorDigest(id: itemId)
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.digest = digest
                uiState.digestLoading = false
            } catch {
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.digestError = AppError.from(error)
                uiState.digestLoading = false
            }
        }
    }

    private func loadBlended(itemId: String, requestId: UUID) {
        uiState.blendedLoading = true

        blendedTask = Task {
            do {
                let query = BlendedRecommendationQuery(type: .inheritor, id: itemId)
                let response = try await repository.blendedRecommendations(query: query)
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.blendedRecommendations = response.items
                uiState.blendedLoading = false
            } catch {
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.blendedLoading = false
            }
        }
    }
}
