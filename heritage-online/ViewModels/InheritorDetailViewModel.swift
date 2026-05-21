import Foundation
import Observation

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

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil,
        repository: HeritageRepositoryProtocol = HeritageRepository()
    ) {
        self.inheritorId = inheritorId
        self.sourceId = sourceId
        self.repository = repository
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
        isFavorite.toggle()
    }
}
