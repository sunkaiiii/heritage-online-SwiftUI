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
    private let savedContentRepo: SavedContentRepository

    private var contentKey: String {
        SavedContent.computeKey(id: articleId, sourceId: sourceId, sourceUrl: sourceUrl)
    }

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news,
        repository: HeritageRepositoryProtocol = HeritageRepository(),
        savedContentRepo: SavedContentRepository
    ) {
        self.articleId = articleId
        self.sourceId = sourceId
        self.sourceUrl = sourceUrl
        self.category = category
        self.repository = repository
        self.savedContentRepo = savedContentRepo
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
        guard let detail = article else { return }
        isFavorite.toggle()
        savedContentRepo.toggleFavorite(
            contentKey: contentKey,
            contentType: "article",
            title: detail.title,
            summary: detail.summary,
            coverImageUrl: detail.coverImage?.previewUrl,
            category: detail.category.rawValue,
            region: nil,
            year: nil,
            sourceUrl: detail.sourceUrl,
            targetId: detail.id,
            targetSourceId: sourceId,
            targetSourceUrl: detail.sourceUrl,
            targetCategory: detail.category.rawValue,
            targetKind: nil
        )
    }

    private func recordViewed(detail: ArticleDetailDto) {
        savedContentRepo.recordViewed(
            contentKey: contentKey,
            contentType: "article",
            title: detail.title,
            summary: detail.summary,
            coverImageUrl: detail.coverImage?.previewUrl,
            category: detail.category.rawValue,
            region: nil,
            year: nil,
            sourceUrl: detail.sourceUrl,
            targetId: detail.id,
            targetSourceId: sourceId,
            targetSourceUrl: detail.sourceUrl,
            targetCategory: detail.category.rawValue,
            targetKind: nil
        )
    }
}
