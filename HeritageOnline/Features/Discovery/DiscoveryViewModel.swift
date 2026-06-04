import Foundation
import SwiftUI

/// 发现页 ViewModel
/// 对齐 Android DiscoveryViewModel
@MainActor
@Observable
final class DiscoveryViewModel {
    var uiState = DiscoveryUiState()

    private let repository: HeritageRepository

    init(repository: HeritageRepository = AppDependencies.shared.heritageRepository) {
        self.repository = repository
        loadAll()
    }

    /// 加载所有区块
    func loadAll() {
        loadToday()
        loadTrending()
        loadWeekly()
        loadClassic()
    }

    /// 加载今日发现
    func loadToday() {
        uiState = DiscoveryUiState(
            today: uiState.today.loading(),
            trending: uiState.trending,
            weekly: uiState.weekly,
            classic: uiState.classic,
            serendipityItem: uiState.serendipityItem,
            serendipityLoading: uiState.serendipityLoading
        )

        Task {
            do {
                let data = try await repository.discoveryToday()
                uiState = DiscoveryUiState(
                    today: DiscoverySectionState(data: data),
                    trending: uiState.trending,
                    weekly: uiState.weekly,
                    classic: uiState.classic,
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            } catch {
                uiState = DiscoveryUiState(
                    today: uiState.today.failed(AppError.from(error)),
                    trending: uiState.trending,
                    weekly: uiState.weekly,
                    classic: uiState.classic,
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            }
        }
    }

    /// 加载趋势内容
    func loadTrending() {
        uiState = DiscoveryUiState(
            today: uiState.today,
            trending: uiState.trending.loading(),
            weekly: uiState.weekly,
            classic: uiState.classic,
            serendipityItem: uiState.serendipityItem,
            serendipityLoading: uiState.serendipityLoading
        )

        Task {
            do {
                let data = try await repository.discoveryTrending(limit: 10)
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: DiscoverySectionState(data: data),
                    weekly: uiState.weekly,
                    classic: uiState.classic,
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            } catch {
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: uiState.trending.failed(AppError.from(error)),
                    weekly: uiState.weekly,
                    classic: uiState.classic,
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            }
        }
    }

    /// 加载本周精选
    func loadWeekly() {
        uiState = DiscoveryUiState(
            today: uiState.today,
            trending: uiState.trending,
            weekly: uiState.weekly.loading(),
            classic: uiState.classic,
            serendipityItem: uiState.serendipityItem,
            serendipityLoading: uiState.serendipityLoading
        )

        Task {
            do {
                let data = try await repository.discoveryWeekly()
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: uiState.trending,
                    weekly: DiscoverySectionState(data: data),
                    classic: uiState.classic,
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            } catch {
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: uiState.trending,
                    weekly: uiState.weekly.failed(AppError.from(error)),
                    classic: uiState.classic,
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            }
        }
    }

    /// 加载经典区块（探索主题、学习路径、精选合集、地区图谱）
    func loadClassic() {
        uiState = DiscoveryUiState(
            today: uiState.today,
            trending: uiState.trending,
            weekly: uiState.weekly,
            classic: uiState.classic.loading(),
            serendipityItem: uiState.serendipityItem,
            serendipityLoading: uiState.serendipityLoading
        )

        Task {
            do {
                // 并行加载多个经典区块
                async let exploreIndexResult = repository.exploreIndex()
                async let topicsResult = repository.exploreTopics(type: "all", limit: 12)
                async let learningPathsResult = repository.learningPaths()
                async let featuredCollectionsResult = repository.featuredCollections()
                async let regionAtlasResult = repository.regionAtlas()

                // 等待所有结果，使用可选 try
                let exploreIndex = try? await exploreIndexResult
                let topics = (try? await topicsResult) ?? []
                let learningPaths = (try? await learningPathsResult) ?? []
                let featuredCollections = (try? await featuredCollectionsResult) ?? []
                let regionAtlas = try? await regionAtlasResult

                let data = DiscoveryClassicData(
                    exploreIndex: exploreIndex,
                    topics: topics,
                    learningPaths: learningPaths,
                    featuredCollections: featuredCollections,
                    regionAtlas: regionAtlas
                )

                let hasAnyData = data.exploreIndex != nil ||
                    !data.topics.isEmpty ||
                    !data.learningPaths.isEmpty ||
                    !data.featuredCollections.isEmpty ||
                    data.regionAtlas != nil

                if hasAnyData {
                    uiState = DiscoveryUiState(
                        today: uiState.today,
                        trending: uiState.trending,
                        weekly: uiState.weekly,
                        classic: DiscoverySectionState(data: data),
                        serendipityItem: uiState.serendipityItem,
                        serendipityLoading: uiState.serendipityLoading
                    )
                } else {
                    // 所有请求都失败了
                    let firstError: AppError = .unknown(nil)
                    uiState = DiscoveryUiState(
                        today: uiState.today,
                        trending: uiState.trending,
                        weekly: uiState.weekly,
                        classic: DiscoverySectionState(error: firstError),
                        serendipityItem: uiState.serendipityItem,
                        serendipityLoading: uiState.serendipityLoading
                    )
                }
            } catch {
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: uiState.trending,
                    weekly: uiState.weekly,
                    classic: uiState.classic.failed(AppError.from(error)),
                    serendipityItem: uiState.serendipityItem,
                    serendipityLoading: uiState.serendipityLoading
                )
            }
        }
    }

    /// 随便看看
    func serendipity() {
        uiState = DiscoveryUiState(
            today: uiState.today,
            trending: uiState.trending,
            weekly: uiState.weekly,
            classic: uiState.classic,
            serendipityItem: uiState.serendipityItem,
            serendipityLoading: true
        )

        Task {
            do {
                let item = try await repository.discoverySerendipity(query: DiscoverySerendipityQuery())
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: uiState.trending,
                    weekly: uiState.weekly,
                    classic: uiState.classic,
                    serendipityItem: item,
                    serendipityLoading: false
                )
            } catch {
                uiState = DiscoveryUiState(
                    today: uiState.today,
                    trending: uiState.trending,
                    weekly: uiState.weekly,
                    classic: uiState.classic,
                    serendipityItem: nil,
                    serendipityLoading: false
                )
            }
        }
    }

    /// 清除随便看看结果
    func clearSerendipity() {
        uiState = DiscoveryUiState(
            today: uiState.today,
            trending: uiState.trending,
            weekly: uiState.weekly,
            classic: uiState.classic,
            serendipityItem: nil,
            serendipityLoading: uiState.serendipityLoading
        )
    }
}
