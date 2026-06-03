import SwiftUI
import Foundation

/// 文章详情页面状态
/// 对齐 Android ArticleDetailUiState
@MainActor
@Observable
final class ArticleDetailUiState {
    var isLoading: Bool = true
    var article: ArticleDetailDTO?
    var error: AppError?
    var isFavorite: Bool = false
    var isContentStale: Bool = false
}

/// 文章详情 ViewModel
/// 对齐 Android ArticleDetailViewModel
@MainActor
@Observable
final class ArticleDetailViewModel {
    let uiState = ArticleDetailUiState()
    private let repository: HeritageRepository
    private let savedRepository: SavedContentRepository
    private let lookup: ArticleDetailLookup
    private var currentSnapshot: SavedContent?

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news,
        repository: HeritageRepository = DefaultHeritageRepository(),
        savedRepository: SavedContentRepository = DefaultSavedContentRepository.shared
    ) {
        self.repository = repository
        self.savedRepository = savedRepository
        self.lookup = ArticleDetailLookup(
            articleId: articleId,
            sourceId: sourceId,
            sourceUrl: sourceUrl,
            category: category
        )
    }

    func refresh() async {
        uiState.isLoading = uiState.article == nil
        uiState.error = nil

        do {
            let article = try await repository.article(lookup: lookup)
            uiState.article = article
            uiState.isLoading = false
            uiState.isContentStale = false

            // 记录最近浏览
            recordViewedIfNew(article)

            // 观察收藏状态
            if let key = currentSnapshot?.contentKey {
                uiState.isFavorite = await savedRepository.isFavorite(key)
            }
        } catch {
            if uiState.article != nil {
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

    private func recordViewedIfNew(_ article: ArticleDetailDTO) {
        let newSnapshot = SavedContent.fromArticle(article)
        if currentSnapshot?.contentKey != newSnapshot.contentKey || currentSnapshot?.title != newSnapshot.title {
            currentSnapshot = newSnapshot
            Task { await savedRepository.recordViewed(newSnapshot) }
        }
    }
}
