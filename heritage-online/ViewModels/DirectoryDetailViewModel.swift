import Foundation
import Observation

@Observable
class DirectoryDetailViewModel {
    var isLoading: Bool = false
    var isContentStale: Bool = false
    var errorMessage: String?
    var item: DirectoryItemDetailDto?
    var isFavorite: Bool = false

    private let itemId: String?
    private let sourceId: String?
    private let kind: DirectoryItemKind
    private let repository: HeritageRepositoryProtocol

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject,
        repository: HeritageRepositoryProtocol = HeritageRepository()
    ) {
        self.itemId = itemId
        self.sourceId = sourceId
        self.kind = kind
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let detail: DirectoryItemDetailDto
            if let id = itemId, !id.isEmpty {
                detail = try await repository.directoryItem(id: id)
            } else if let sourceId = sourceId, !sourceId.isEmpty {
                detail = try await repository.directoryItemBySourceId(sourceId, kind: kind)
            } else {
                errorMessage = String(localized: "content_not_available")
                isLoading = false
                return
            }
            item = detail
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func refresh() async {
        isContentStale = false
        errorMessage = nil
        do {
            let detail: DirectoryItemDetailDto
            if let id = itemId, !id.isEmpty {
                detail = try await repository.directoryItem(id: id)
            } else if let sourceId = sourceId, !sourceId.isEmpty {
                detail = try await repository.directoryItemBySourceId(sourceId, kind: kind)
            } else {
                return
            }
            item = detail
        } catch {
            isContentStale = true
        }
    }

    func toggleFavorite() {
        isFavorite.toggle()
    }
}
