import Foundation
import Observation

@MainActor
@Observable
class InheritorDetailViewModel {
    var isLoading: Bool = false
    var isContentStale: Bool = false
    var errorMessage: String?
    var item: InheritorDetailDto?
    var isFavorite: Bool = false

    private let inheritorId: String?
    private let sourceId: String?
    private let repository: HeritageRepositoryProtocol
    private let savedContentRepo: SavedContentRepository

    private var contentKey: String {
        SavedContent.computeKey(id: inheritorId, sourceId: sourceId, sourceUrl: nil)
    }

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil,
        repository: HeritageRepositoryProtocol = HeritageRepository(),
        savedContentRepo: SavedContentRepository
    ) {
        self.inheritorId = inheritorId
        self.sourceId = sourceId
        self.repository = repository
        self.savedContentRepo = savedContentRepo
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let detail: InheritorDetailDto
            if let id = inheritorId, !id.isEmpty {
                detail = try await repository.inheritor(id: id)
            } else if let sourceId = sourceId, !sourceId.isEmpty {
                detail = try await repository.inheritorBySourceId(sourceId)
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
            let detail: InheritorDetailDto
            if let id = inheritorId, !id.isEmpty {
                detail = try await repository.inheritor(id: id)
            } else if let sourceId = sourceId, !sourceId.isEmpty {
                detail = try await repository.inheritorBySourceId(sourceId)
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
            contentType: "inheritor",
            title: detail.name,
            summary: detail.description,
            coverImageUrl: detail.coverImage?.previewUrl,
            category: detail.category,
            region: detail.region,
            year: nil,
            sourceUrl: detail.sourceUrl,
            targetId: detail.id,
            targetSourceId: sourceId,
            targetSourceUrl: detail.sourceUrl,
            targetCategory: detail.category,
            targetKind: nil
        )
    }

    private func recordViewed(detail: InheritorDetailDto) {
        savedContentRepo.recordViewed(
            contentKey: contentKey,
            contentType: "inheritor",
            title: detail.name,
            summary: detail.description,
            coverImageUrl: detail.coverImage?.previewUrl,
            category: detail.category,
            region: detail.region,
            year: nil,
            sourceUrl: detail.sourceUrl,
            targetId: detail.id,
            targetSourceId: sourceId,
            targetSourceUrl: detail.sourceUrl,
            targetCategory: detail.category,
            targetKind: nil
        )
    }
}
