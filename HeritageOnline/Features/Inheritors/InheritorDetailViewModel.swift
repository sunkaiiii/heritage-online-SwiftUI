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
    private let lookup: InheritorDetailLookup

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil,
        repository: HeritageRepository = DefaultHeritageRepository()
    ) {
        self.repository = repository
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
