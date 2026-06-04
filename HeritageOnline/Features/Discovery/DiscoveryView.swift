import SwiftUI

/// 发现页主视图
/// 对齐 Android DiscoveryScreen
/// 实现今日发现、趋势、本周精选、探索主题、学习路径、精选合集等区块
struct DiscoveryView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel = DiscoveryViewModel()

    // 导航状态
    @State private var searchQuery = ""
    @State private var navigateToSearch = false
    @State private var navigateToTopic: ExploreTopicInfoDTO?
    @State private var navigateToLearningPath: LearningPathDTO?
    @State private var navigateToCollection: FeaturedCollectionDTO?
    @State private var navigateToRegionAtlas = false
    @State private var navigateToTimeline = false
    @State private var navigateToTaxonomy = false
    @State private var navigateToStories = false
    @State private var navigateToDeepDive: DiscoveryItemDTO?
    @State private var navigateToArticleDetail: String?
    @State private var navigateToDirectoryDetail: String?
    @State private var navigateToInheritorDetail: String?

    var body: some View {
        PageBackground {
            ZStack {
                // 全页 loading：所有区块都在加载且没有任何数据
                if viewModel.uiState.isAnyLoading &&
                    !viewModel.uiState.today.hasData &&
                    !viewModel.uiState.trending.hasData &&
                    !viewModel.uiState.weekly.hasData &&
                    !viewModel.uiState.classic.hasData {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.uiState.isAllFailed {
                    // 全页错误
                    DiscoveryErrorContent(
                        error: viewModel.uiState.today.error ?? .unknown(nil),
                        onRetry: { viewModel.loadAll() }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 正常内容
                    DiscoveryContent(
                        uiState: viewModel.uiState,
                        onRefresh: { viewModel.loadAll() },
                        onSearchSubmit: { query in
                            searchQuery = query
                            navigateToSearch = true
                        },
                        onTopicClick: { topic in
                            navigateToTopic = topic
                        },
                        onLearningPathClick: { path in
                            navigateToLearningPath = path
                        },
                        onCollectionClick: { collection in
                            navigateToCollection = collection
                        },
                        onRegionAtlasClick: {
                            navigateToRegionAtlas = true
                        },
                        onTimelineClick: {
                            navigateToTimeline = true
                        },
                        onSerendipityClick: {
                            viewModel.serendipity()
                        },
                        onTrendingItemClick: { item in
                            handleItemClick(item)
                        },
                        onWeeklyItemClick: { item in
                            handleItemClick(item)
                        },
                        onTodayItemClick: { item in
                            handleItemClick(item)
                        },
                        onDeepDiveClick: { item in
                            // 只有 id 非空且 type 合法才允许导航
                            guard let id = item.id, !id.isEmpty,
                                  SearchResultType(rawValue: item.type) != nil else { return }
                            navigateToDeepDive = item
                        },
                        onTaxonomyClick: {
                            navigateToTaxonomy = true
                        },
                        onStoriesClick: {
                            navigateToStories = true
                        },
                        onRetryToday: { viewModel.loadToday() },
                        onRetryTrending: { viewModel.loadTrending() },
                        onRetryWeekly: { viewModel.loadWeekly() },
                        onRetryClassic: { viewModel.loadClassic() }
                    )
                }
            }
        }
        .navigationTitle("tab.discovery")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .task {
            viewModel.loadAll()
        }
        .navigationDestination(isPresented: $navigateToSearch) {
            SearchView(
                initialQuery: searchQuery,
                onBack: { navigateToSearch = false },
                onArticleSelected: { id in
                    navigateToSearch = false
                    navigateToArticleDetail = id
                },
                onDirectoryItemSelected: { id in
                    navigateToSearch = false
                    navigateToDirectoryDetail = id
                },
                onInheritorSelected: { id in
                    navigateToSearch = false
                    navigateToInheritorDetail = id
                }
            )
        }
        .navigationDestination(item: $navigateToTopic) { topic in
            ExploreTopicView(type: topic.type ?? "", key: topic.key ?? "")
        }
        .navigationDestination(item: $navigateToLearningPath) { path in
            LearningPathView(id: path.id ?? "")
        }
        .navigationDestination(item: $navigateToCollection) { collection in
            CollectionDetailView(id: collection.id ?? "")
        }
        .navigationDestination(isPresented: $navigateToRegionAtlas) {
            RegionAtlasView()
        }
        .navigationDestination(isPresented: $navigateToTimeline) {
            TimelineView()
        }
        .navigationDestination(isPresented: $navigateToTaxonomy) {
            TaxonomyView()
        }
        .navigationDestination(isPresented: $navigateToStories) {
            StoriesIndexView()
        }
        .navigationDestination(item: $navigateToDeepDive) { item in
            if let seedType = SearchResultType(rawValue: item.type), let seedId = item.id {
                DiscoveryDeepDiveView(seedType: seedType, seedId: seedId)
            } else {
                // 防御性兜底：上游 guard 正常时不会走到这里
                PlaceholderDetailView(titleKey: "discovery.deepDive")
            }
        }
        .navigationDestination(item: $navigateToArticleDetail) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToDirectoryDetail) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToInheritorDetail) { id in
            InheritorDetailView(inheritorId: id)
        }
    }

    /// 处理内容项点击
    private func handleItemClick(_ item: DiscoveryItemDTO) {
        guard let id = item.id, !id.isEmpty else { return }
        switch item.type {
        case "article":
            navigateToArticleDetail = id
        case "directoryItem":
            navigateToDirectoryDetail = id
        case "inheritor":
            navigateToInheritorDetail = id
        default:
            break
        }
    }
}

