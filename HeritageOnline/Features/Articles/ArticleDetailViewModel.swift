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
/// 先观察缓存，再刷新网络；网络失败但有缓存时显示正文和 stale 提示
@MainActor
@Observable
final class ArticleDetailViewModel {
    let uiState = ArticleDetailUiState()
    private let repository: HeritageRepository
    private let savedRepository: SavedContentRepository
    private let lookup: ArticleDetailLookup
    private var currentSnapshot: SavedContent?

    /// 请求 ID，用于防止旧请求覆盖新数据
    private var requestId: UUID = UUID()

    /// 运行中的附加区块 task
    private var contextTask: Task<Void, Never>?
    private var digestTask: Task<Void, Never>?
    private var blendedTask: Task<Void, Never>?

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news,
        repository: HeritageRepository = AppDependencies.shared.heritageRepository,
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
        let id = UUID()
        requestId = id

        // 取消旧的附加区块 task
        contextTask?.cancel()
        digestTask?.cancel()
        blendedTask?.cancel()

        // 先尝试从缓存读取（如果有缓存，立即显示）
        if uiState.article == nil {
            let cached = await repository.cachedArticleDetail(lookup: lookup)
            if let cached, requestId == id {
                uiState.article = cached
                uiState.isLoading = false
                recordViewedIfNew(cached)
            }
        }

        uiState.isLoading = uiState.article == nil
        uiState.error = nil

        do {
            let article = try await repository.article(lookup: lookup)

            // 检查请求是否仍然有效
            guard requestId == id else { return }

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
                loadContext(articleId: articleId, requestId: id)
                loadDigest(articleId: articleId, requestId: id)
                loadBlended(articleId: articleId, requestId: id)
            }
        } catch {
            guard requestId == id else { return }
            if uiState.article != nil {
                // 有缓存内容，标记为 stale
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
            loadContext(articleId: articleId, requestId: requestId)
        }
    }

    func retryDigest() {
        if let articleId = uiState.article?.id {
            loadDigest(articleId: articleId, requestId: requestId)
        }
    }

    private func loadContext(articleId: String, requestId: UUID) {
        uiState.contextLoading = true
        uiState.contextError = nil

        contextTask = Task {
            do {
                let context = try await repository.articleContext(id: articleId)
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.context = context
                uiState.contextLoading = false
            } catch {
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.contextError = AppError.from(error)
                uiState.contextLoading = false
            }
        }
    }

    private func loadDigest(articleId: String, requestId: UUID) {
        uiState.digestLoading = true
        uiState.digestError = nil

        digestTask = Task {
            do {
                let digest = try await repository.articleDigest(id: articleId)
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.digest = digest
                uiState.digestLoading = false
            } catch {
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.digestError = AppError.from(error)
                uiState.digestLoading = false
            }
        }
    }

    private func loadBlended(articleId: String, requestId: UUID) {
        uiState.blendedLoading = true

        blendedTask = Task {
            do {
                let query = BlendedRecommendationQuery(type: .article, id: articleId)
                let response = try await repository.blendedRecommendations(query: query)
                guard !Task.isCancelled, self.requestId == requestId else { return }
                uiState.blendedRecommendations = response.items
                uiState.blendedLoading = false
            } catch {
                guard !Task.isCancelled, self.requestId == requestId else { return }
                // 综合推荐失败不显示错误，静默处理
                uiState.blendedLoading = false
            }
        }
    }
}
