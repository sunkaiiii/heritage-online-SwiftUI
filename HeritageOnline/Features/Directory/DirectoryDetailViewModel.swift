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
    private let lookup: DirectoryDetailLookup

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject,
        repository: HeritageRepository = DefaultHeritageRepository()
    ) {
        self.repository = repository
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
        } catch {
            if uiState.item != nil {
                uiState.isContentStale = true
            } else {
                uiState.error = AppError.from(error)
            }
            uiState.isLoading = false
        }
    }

    func toggleFavorite() {
        uiState.isFavorite.toggle()
    }
}
