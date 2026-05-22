import Foundation
import Observation

@MainActor
@Observable
class ArticlesViewModel {
    var selectedCategory: ArticleCategory = .news
    var searchKeywords: String = ""
    var yearFilter: String = ""
    var isLoadingBanners: Bool = true
    var banners: [HomeBannerDto] = []
    var bannerError: String?

    var articles: [ArticleSummaryDto] = []
    var isLoadingArticles: Bool = false
    var isLoadingMore: Bool = false
    var articleError: String?
    var hasMoreArticles: Bool = true
    private var currentPage: Int = 1

    private let repository: HeritageRepositoryProtocol

    init(repository: HeritageRepositoryProtocol = HeritageRepository()) {
        self.repository = repository
    }

    func loadBanners() async {
        isLoadingBanners = true
        bannerError = nil
        do {
            banners = try await repository.homeBanners()
            isLoadingBanners = false
        } catch {
            if banners.isEmpty {
                bannerError = error.localizedDescription
            }
            isLoadingBanners = false
        }
    }

    func loadArticles() async {
        isLoadingArticles = true
        articleError = nil
        currentPage = 1
        hasMoreArticles = true

        let query = ArticleQuery(
            category: selectedCategory,
            page: 1,
            pageSize: 20,
            year: Int(yearFilter),
            keywords: searchKeywords.isEmpty ? nil : searchKeywords
        )

        do {
            let result = try await repository.articles(query: query)
            articles = result.items
            hasMoreArticles = result.hasMore
            currentPage = 1
            isLoadingArticles = false
        } catch {
            articleError = error.localizedDescription
            isLoadingArticles = false
        }
    }

    func loadMoreArticles() async {
        guard !isLoadingMore, hasMoreArticles else { return }
        isLoadingMore = true

        let nextPage = currentPage + 1
        let query = ArticleQuery(
            category: selectedCategory,
            page: nextPage,
            pageSize: 20,
            year: Int(yearFilter),
            keywords: searchKeywords.isEmpty ? nil : searchKeywords
        )

        do {
            let result = try await repository.articles(query: query)
            articles.append(contentsOf: result.items)
            hasMoreArticles = result.hasMore
            currentPage = nextPage
            isLoadingMore = false
        } catch {
            isLoadingMore = false
        }
    }

    func refresh() async {
        await loadBanners()
        await loadArticles()
    }
}
