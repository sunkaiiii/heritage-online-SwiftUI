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

    // 探索区状态
    var digest: ContentDigestDTO?
    var digestLoading: Bool = false
    var digestError: AppError?

    var context: DetailContextDTO?
    var contextLoading: Bool = false
    var contextError: AppError?

    var blendedRecommendations: [BlendedRecommendationItemDTO] = []
    var blendedLoading: Bool = false
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

            // 加载探索区数据
            if let articleId = article.id {
                loadContext(articleId: articleId)
                loadDigest(articleId: articleId)
                loadBlended(articleId: articleId)
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

    // MARK: - 探索区加载

    func retryContext() {
        if let articleId = uiState.article?.id {
            loadContext(articleId: articleId)
        }
    }

    func retryDigest() {
        if let articleId = uiState.article?.id {
            loadDigest(articleId: articleId)
        }
    }

    private func loadContext(articleId: String) {
        uiState.contextLoading = true
        uiState.contextError = nil

        Task {
            do {
                let context = try await repository.articleContext(id: articleId)
                uiState.context = context
                uiState.contextLoading = false
            } catch {
                uiState.contextError = AppError.from(error)
                uiState.contextLoading = false
            }
        }
    }

    private func loadDigest(articleId: String) {
        uiState.digestLoading = true
        uiState.digestError = nil

        Task {
            do {
                let digest = try await repository.articleDigest(id: articleId)
                uiState.digest = digest
                uiState.digestLoading = false
            } catch {
                uiState.digestError = AppError.from(error)
                uiState.digestLoading = false
            }
        }
    }

    private func loadBlended(articleId: String) {
        uiState.blendedLoading = true

        Task {
            do {
                let query = BlendedRecommendationQuery(type: .article, id: articleId)
                let response = try await repository.blendedRecommendations(query: query)
                uiState.blendedRecommendations = response.items
                uiState.blendedLoading = false
            } catch {
                // 综合推荐失败不显示错误，静默处理
                uiState.blendedLoading = false
            }
        }
    }
}
