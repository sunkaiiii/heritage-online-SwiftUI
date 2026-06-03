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

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil,
        repository: HeritageRepository = DefaultHeritageRepository(),
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
        uiState.isLoading = uiState.item == nil
        uiState.error = nil

        do {
            let item = try await repository.inheritor(lookup: lookup)
            uiState.item = item
            uiState.isLoading = false
            uiState.isContentStale = false

            recordViewedIfNew(item)
            if let key = currentSnapshot?.contentKey {
                uiState.isFavorite = await savedRepository.isFavorite(key)
            }
        } catch {
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
}
