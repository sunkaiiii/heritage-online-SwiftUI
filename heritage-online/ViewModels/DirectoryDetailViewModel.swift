import Foundation
import Observation

@MainActor
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
    private let savedContentRepo: SavedContentRepository

    private var contentKey: String {
        SavedContent.computeKey(id: itemId, sourceId: sourceId, sourceUrl: nil, kind: kind.rawValue)
    }

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject,
        repository: HeritageRepositoryProtocol = HeritageRepository(),
        savedContentRepo: SavedContentRepository
    ) {
        self.itemId = itemId
        self.sourceId = sourceId
        self.kind = kind
        self.repository = repository
        self.savedContentRepo = savedContentRepo
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
            isFavorite = savedContentRepo.isFavorite(contentKey: contentKey)
            recordViewed(detail: detail)
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
        guard let detail = item else { return }
        isFavorite.toggle()
        savedContentRepo.toggleFavorite(
            contentKey: contentKey,
            contentType: "directoryItem",
            title: detail.title,
            summary: detail.summary,
            coverImageUrl: detail.coverImage?.previewUrl,
            category: detail.category,
            region: detail.region,
            year: detail.publishedYear,
            sourceUrl: detail.sourceUrl,
            targetId: detail.id,
            targetSourceId: sourceId,
            targetSourceUrl: detail.sourceUrl,
            targetCategory: detail.category,
            targetKind: detail.kind.rawValue
        )
    }

    private func recordViewed(detail: DirectoryItemDetailDto) {
        savedContentRepo.recordViewed(
            contentKey: contentKey,
            contentType: "directoryItem",
            title: detail.title,
            summary: detail.summary,
            coverImageUrl: detail.coverImage?.previewUrl,
            category: detail.category,
            region: detail.region,
            year: detail.publishedYear,
            sourceUrl: detail.sourceUrl,
            targetId: detail.id,
            targetSourceId: sourceId,
            targetSourceUrl: detail.sourceUrl,
            targetCategory: detail.category,
            targetKind: detail.kind.rawValue
        )
    }
}
