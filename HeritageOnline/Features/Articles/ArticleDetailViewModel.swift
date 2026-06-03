import SwiftUI
import Foundation

/// 文章详情页面状态
/// 对齐 Android ArticleDetailUiState
/// Step 11 范围：主体内容 + 收藏占位
@MainActor
@Observable
final class ArticleDetailUiState {
    /// 加载中
    var isLoading: Bool = true
    /// 文章详情
    var article: ArticleDetailDTO?
    /// 错误
    var error: AppError?
    /// 是否收藏（占位，Step 16 完整实现）
    var isFavorite: Bool = false
    /// 内容是否过期（网络失败但有旧数据时）
    var isContentStale: Bool = false
}

/// 文章详情 ViewModel
/// 对齐 Android ArticleDetailViewModel
/// Step 11 范围：详情加载 + 收藏占位
@MainActor
@Observable
final class ArticleDetailViewModel {
    let uiState = ArticleDetailUiState()
    private let repository: HeritageRepository
    private let lookup: ArticleDetailLookup

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news,
        repository: HeritageRepository = DefaultHeritageRepository()
    ) {
        self.repository = repository
        self.lookup = ArticleDetailLookup(
            articleId: articleId,
            sourceId: sourceId,
            sourceUrl: sourceUrl,
            category: category
        )
    }

    /// 刷新文章详情
    func refresh() async {
        uiState.isLoading = uiState.article == nil
        uiState.error = nil

        do {
            let article = try await repository.article(lookup: lookup)
            uiState.article = article
            uiState.isLoading = false
            uiState.isContentStale = false
        } catch {
            if uiState.article != nil {
                // 有旧数据时标记过期，不覆盖正文
                uiState.isContentStale = true
            } else {
                uiState.error = AppError.from(error)
            }
            uiState.isLoading = false
        }
    }

    /// 切换收藏状态（占位，Step 16 完整实现）
    func toggleFavorite() {
        uiState.isFavorite.toggle()
    }
}
