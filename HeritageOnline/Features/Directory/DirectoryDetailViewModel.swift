import SwiftUI
import Foundation

/// 名录详情页面状态
/// 对齐 Android DirectoryDetailUiState
@MainActor
@Observable
final class DirectoryDetailUiState {
    var isLoading: Bool = true
    var item: DirectoryItemDetailDTO?
    var error: AppError?
    var isFavorite: Bool = false
    var isContentStale: Bool = false
}

/// 名录详情 ViewModel
/// 对齐 Android DirectoryDetailViewModel
@MainActor
@Observable
final class DirectoryDetailViewModel {
    let uiState = DirectoryDetailUiState()
    private let repository: HeritageRepository
    private let savedRepository: SavedContentRepository
    private let lookup: DirectoryDetailLookup
    private var currentSnapshot: SavedContent?

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject,
        repository: HeritageRepository = DefaultHeritageRepository(),
        savedRepository: SavedContentRepository = DefaultSavedContentRepository.shared
    ) {
        self.repository = repository
        self.savedRepository = savedRepository
        self.lookup = DirectoryDetailLookup(
            itemId: itemId,
            sourceId: sourceId,
            kind: kind
        )
    }

    func refresh() async {
        uiState.isLoading = uiState.item == nil
        uiState.error = nil

        do {
            let item = try await repository.directoryItem(lookup: lookup)
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

    private func recordViewedIfNew(_ item: DirectoryItemDetailDTO) {
        let newSnapshot = SavedContent.fromDirectoryItem(item)
        if currentSnapshot?.contentKey != newSnapshot.contentKey || currentSnapshot?.title != newSnapshot.title {
            currentSnapshot = newSnapshot
            Task { await savedRepository.recordViewed(newSnapshot) }
        }
    }
}
