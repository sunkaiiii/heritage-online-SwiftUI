import SwiftUI

/// 深度探索页
/// 展示 seed 内容和相关推荐列表
struct DiscoveryDeepDiveView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: DiscoveryDeepDiveViewModel

    /// 子导航状态
    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?

    init(seedType: SearchResultType, seedId: String) {
        _viewModel = State(initialValue: DiscoveryDeepDiveViewModel(
            seedType: seedType,
            seedId: seedId
        ))
    }

    var body: some View {
        PageBackground {
            Group {
                if viewModel.isLoading {
                    LoadingPlaceholder()
                } else if let error = viewModel.error {
                    errorView(error)
                } else {
                    contentView
                }
            }
        }
        .navigationTitle("discovery.deepDive")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .task { await viewModel.load() }
        .navigationDestination(item: $navigateToArticle) { articleId in
            ArticleDetailView(articleId: articleId)
        }
        .navigationDestination(item: $navigateToDirectory) { itemId in
            DirectoryDetailView(itemId: itemId)
        }
        .navigationDestination(item: $navigateToInheritor) { inheritorId in
            InheritorDetailView(inheritorId: inheritorId)
        }
    }

    // MARK: - 内容

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Seed 内容
                if let seed = viewModel.seed {
                    seedSection(seed)
                }

                // 相关推荐
                if !viewModel.related.isEmpty {
                    relatedSection
                }

                // 生成时间
                if let generatedAt = viewModel.generatedAt {
                    Text("discovery.generatedAt \(generatedAt)")
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
    }

    // MARK: - Seed 区块

    private func seedSection(_ item: DiscoveryItemDTO) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("discovery.deepDive.seed")
                .font(HeritageTypography.headlineMedium)
                .foregroundStyle(colorScheme.onBackground)

            DiscoveryItemRow(item: item) {
                navigateToItem(item)
            }
        }
    }

    // MARK: - 相关推荐区块

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("discovery.deepDive.related")
                .font(HeritageTypography.headlineMedium)
                .foregroundStyle(colorScheme.onBackground)

            ForEach(viewModel.related, id: \.sourceUrl) { item in
                DiscoveryItemRow(item: item) {
                    navigateToItem(item)
                }
            }
        }
    }

    // MARK: - 错误视图

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(error.localizedDescription)
                .font(HeritageTypography.bodyLarge)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button("action.retry") {
                Task { await viewModel.retry() }
            }
            .buttonStyle(.borderedProminent)
            .tint(colorScheme.primary)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - 导航

    private func navigateToItem(_ item: DiscoveryItemDTO) {
        guard let id = item.id else { return }
        switch item.type {
        case "article":
            navigateToArticle = id
        case "directoryItem":
            navigateToDirectory = id
        case "inheritor":
            navigateToInheritor = id
        default:
            break
        }
    }
}
