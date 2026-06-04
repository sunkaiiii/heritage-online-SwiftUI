import Foundation

/// 时间线页面 ViewModel
/// 对齐 Android TimelineViewModel
/// 管理年份加载、内容加载、分页、类型筛选
@MainActor
@Observable
final class TimelineViewModel {
    var isLoading = true
    var years: [TimelineYearBucketDTO] = []
    var selectedYear: Int? = nil
    var items: [TimelineItemDTO] = []
    var page = 1
    var hasMore = false
    var facets: [FacetBucketDTO] = []
    var selectedTypes: Set<SearchResultType> = []
    var isLoadingMore = false
    var error: AppError?

    private let repository: HeritageRepository
    private let pageSize = 20

    /// 请求令牌，防止旧请求回写（快速切换年份/类型时）
    private var loadToken: UUID = UUID()

    init(repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.repository = repository
    }

    // MARK: - 公开方法

    /// 加载年份列表
    func loadYears() {
        isLoading = true
        error = nil

        Task {
            do {
                let data = try await repository.timelineYears()
                years = data
                isLoading = false
            } catch {
                self.error = AppError.from(error)
                isLoading = false
            }
        }
    }

    /// 选择年份（再次点击同一年份取消选择）
    func selectYear(_ year: Int?) {
        if selectedYear == year {
            // 取消选择
            selectedYear = nil
            items = []
            page = 1
            hasMore = false
            facets = []
            error = nil
            return
        }

        selectedYear = year
        items = []
        page = 1
        hasMore = false
        facets = []
        error = nil
        loadToken = UUID()

        if year != nil {
            loadItems(reset: true, token: loadToken)
        }
    }

    /// 切换类型筛选
    func toggleType(_ type: SearchResultType) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }

        // 切换筛选后重置列表
        items = []
        page = 1
        hasMore = false
        error = nil
        loadToken = UUID()

        if selectedYear != nil {
            loadItems(reset: true, token: loadToken)
        }
    }

    /// 加载更多
    func loadMore() {
        guard !isLoadingMore, hasMore, selectedYear != nil else { return }
        loadItems(reset: false, token: loadToken)
    }

    /// 清除错误
    func clearError() {
        error = nil
    }

    /// 重试加载当前年份内容（用于错误状态重试）
    func retryLoad() {
        guard selectedYear != nil else { return }
        error = nil
        loadToken = UUID()
        loadItems(reset: true, token: loadToken)
    }

    // MARK: - 私有方法

    /// 加载内容
    private func loadItems(reset: Bool, token: UUID) {
        let targetPage = reset ? 1 : page + 1

        if reset {
            isLoading = true
        } else {
            isLoadingMore = true
        }

        Task {
            do {
                let query = TimelineV2Query(
                    year: selectedYear,
                    types: selectedTypes,
                    page: targetPage,
                    pageSize: pageSize
                )
                let response = try await repository.timelineV2(query: query)

                // 防止旧请求回写
                guard !Task.isCancelled, loadToken == token else { return }

                if reset {
                    items = response.items
                } else {
                    items.append(contentsOf: response.items)
                }
                page = response.page
                hasMore = response.hasMore
                facets = response.facets?.types ?? []
                isLoading = false
                isLoadingMore = false
            } catch {
                guard !Task.isCancelled, loadToken == token else { return }
                self.error = AppError.from(error)
                isLoading = false
                isLoadingMore = false
            }
        }
    }
}
