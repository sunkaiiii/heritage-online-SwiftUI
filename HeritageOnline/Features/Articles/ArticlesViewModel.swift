import Foundation
import SwiftUI
import Combine

/// 文章列表页面状态
/// 对齐 Android ArticlesUiState
@MainActor
@Observable
final class ArticlesUiState {
    /// 当前选中的文章分类
    var selectedCategory: ArticleCategory = .news

    /// 搜索关键词
    var searchKeywords: String = ""

    /// 年份筛选（字符串形式，用于输入框）
    var yearFilter: String = ""

    /// Banner 加载状态
    var isLoadingBanners: Bool = true

    /// Banner 列表
    var banners: [HomeBannerDTO] = []

    /// Banner 错误
    var bannerError: AppError? = nil

    /// 文章列表
    var articles: [ArticleSummaryDTO] = []

    /// 当前页码
    var currentPage: Int = 1

    /// 是否有更多数据
    var hasMore: Bool = true

    /// 首次加载中
    var isLoading: Bool = true

    /// 追加加载中
    var isLoadingMore: Bool = false

    /// 错误类型
    var error: AppError? = nil

    /// 追加加载错误
    var appendError: AppError? = nil

    /// 活跃筛选数量
    var activeFilterCount: Int {
        var count = 0
        if !yearFilter.trimmingCharacters(in: .whitespaces).isEmpty { count += 1 }
        return count
    }
}

/// 文章列表 ViewModel
/// 对齐 Android ArticlesViewModel
/// 管理文章列表、Banner、搜索、筛选状态
@MainActor
@Observable
final class ArticlesViewModel {
    /// 页面状态
    let uiState = ArticlesUiState()

    /// Repository 引用
    private let repository: HeritageRepository

    /// 搜索防抖 Task
    private var searchTask: Task<Void, Never>?

    /// 分类切换防抖 Task
    private var categoryTask: Task<Void, Never>?

    /// 分页防重入：记录正在加载的页码
    private var loadingMorePage: Int?

    init(repository: HeritageRepository = DefaultHeritageRepository()) {
        self.repository = repository
    }

    // MARK: - 数据加载

    /// 加载首页 Banner
    func loadBanners() async {
        uiState.isLoadingBanners = true
        uiState.bannerError = nil

        do {
            let banners = try await repository.homeBanners()
            uiState.banners = banners
            uiState.isLoadingBanners = false
        } catch {
            uiState.bannerError = AppError.from(error)
            uiState.isLoadingBanners = false
        }
    }

    /// 加载文章列表（首次或刷新）
    func loadArticles() async {
        uiState.isLoading = true
        uiState.error = nil
        uiState.currentPage = 1
        loadingMorePage = nil

        let query = buildQuery(page: 1)

        do {
            let result = try await repository.articles(query: query)
            uiState.articles = result.items
            uiState.hasMore = result.hasMore
            uiState.isLoading = false
        } catch {
            uiState.error = AppError.from(error)
            uiState.isLoading = false
        }
    }

    /// 加载更多文章
    func loadMore() async {
        let nextPage = uiState.currentPage + 1

        // 页级别防重入：如果已经在加载这一页，直接返回
        guard !uiState.isLoadingMore, uiState.hasMore, loadingMorePage != nextPage else { return }

        uiState.isLoadingMore = true
        uiState.appendError = nil
        loadingMorePage = nextPage

        let query = buildQuery(page: nextPage)

        do {
            let result = try await repository.articles(query: query)
            uiState.articles.append(contentsOf: result.items)
            uiState.hasMore = result.hasMore
            uiState.currentPage = nextPage
            uiState.isLoadingMore = false
        } catch {
            uiState.appendError = AppError.from(error)
            uiState.isLoadingMore = false
        }
        loadingMorePage = nil
    }

    /// 刷新全部数据
    func refresh() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadBanners() }
            group.addTask { await self.loadArticles() }
        }
    }

    // MARK: - 筛选操作

    /// 选择文章分类
    func selectCategory(_ category: ArticleCategory) {
        guard uiState.selectedCategory != category else { return }
        uiState.selectedCategory = category
        // 防抖：350ms 后重新加载
        categoryTask?.cancel()
        categoryTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await self.loadArticles()
        }
    }

    /// 更新搜索关键词
    func updateSearchKeywords(_ keywords: String) {
        uiState.searchKeywords = keywords
        // 防抖：350ms 后重新加载
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await self.loadArticles()
        }
    }

    /// 应用年份筛选
    func applyYearFilter(_ year: String) {
        let trimmed = year.trimmingCharacters(in: .whitespaces)
        // 非空时校验必须为 4 位数字
        if !trimmed.isEmpty {
            guard YearFilterValidator.isValidYear(trimmed) else {
                uiState.error = .validationError(String(localized: "filter.invalidYear"))
                return
            }
        }
        uiState.yearFilter = year
        uiState.error = nil
        Task { await self.loadArticles() }
    }

    /// 清除年份筛选
    func clearYearFilter() {
        uiState.yearFilter = ""
        Task { await self.loadArticles() }
    }

    /// 清除所有筛选
    func clearFilters() {
        uiState.yearFilter = ""
        uiState.searchKeywords = ""
        uiState.selectedCategory = .news
        Task { await self.loadArticles() }
    }

    // MARK: - 内部方法

    /// 构建查询参数
    private func buildQuery(page: Int) -> ArticleQuery {
        let trimmedKeywords = uiState.searchKeywords.trimmingCharacters(in: .whitespaces)
        let year = YearFilterValidator.parseInt(uiState.yearFilter)

        return ArticleQuery(
            category: uiState.selectedCategory,
            page: page,
            pageSize: 20,
            year: year,
            keywords: trimmedKeywords.isEmpty ? nil : trimmedKeywords
        )
    }
}
