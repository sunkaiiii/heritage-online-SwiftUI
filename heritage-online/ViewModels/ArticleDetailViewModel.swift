import Foundation
import Observation

@Observable
class ArticleDetailViewModel {
    var isLoading: Bool = false
    var isContentStale: Bool = false
    var errorMessage: String?
    var article: ArticleDetailDto?
    var isFavorite: Bool = false

    private let articleId: String?
    private let sourceId: String?
    private let sourceUrl: String?
    private let category: ArticleCategory
    private let repository: HeritageRepositoryProtocol

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news,
        repository: HeritageRepositoryProtocol = HeritageRepository()
    ) {
        self.articleId = articleId
        self.sourceId = sourceId
        self.sourceUrl = sourceUrl
        self.category = category
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let detail: ArticleDetailDto
            if let id = articleId, !id.isEmpty {
                detail = try await repository.article(id: id)
            } else if let sourceId = sourceId, !sourceId.isEmpty {
                detail = try await repository.articleBySourceId(sourceId, category: category)
            } else if let sourceUrl = sourceUrl, !sourceUrl.isEmpty {
                detail = try await repository.articleBySourceUrl(sourceUrl, category: category)
            } else {
                errorMessage = String(localized: "content_not_available")
                isLoading = false
                return
            }
            article = detail
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
            let detail: ArticleDetailDto
            if let id = articleId, !id.isEmpty {
                detail = try await repository.article(id: id)
            } else if let sourceId = sourceId, !sourceId.isEmpty {
                detail = try await repository.articleBySourceId(sourceId, category: category)
            } else if let sourceUrl = sourceUrl, !sourceUrl.isEmpty {
                detail = try await repository.articleBySourceUrl(sourceUrl, category: category)
            } else {
                errorMessage = String(localized: "content_not_available")
                return
            }
            article = detail
        } catch {
            isContentStale = true
        }
    }

    func toggleFavorite() {
        isFavorite.toggle()
    }
}
