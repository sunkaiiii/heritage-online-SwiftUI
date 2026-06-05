import SwiftUI

/// 深度探索页
/// 展示 seed 内容和相关推荐列表
struct DiscoveryDeepDiveView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: DiscoveryDeepDiveViewModel

    /// 统一导航路由状态
    @State private var navigationRoute: AppRoute?

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
        .navigationDestination(item: $navigationRoute) { route in
            destinationView(for: route)
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

            ForEach(viewModel.related, id: \.stableListID) { item in
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

    @ViewBuilder
    private func destinationView(for route: AppRoute) -> some View {
        switch route {
        case .article(let articleId, let sourceId, let sourceUrl, let category):
            ArticleDetailView(
                articleId: articleId,
                sourceId: sourceId,
                sourceUrl: sourceUrl,
                category: category
            )
        case .directory(let itemId, let sourceId, let kind):
            DirectoryDetailView(
                itemId: itemId,
                sourceId: sourceId,
                kind: kind
            )
        case .inheritor(let inheritorId, let sourceId):
            InheritorDetailView(
                inheritorId: inheritorId,
                sourceId: sourceId
            )
        }
    }

    private func navigateToItem(_ item: DiscoveryItemDTO) {
        switch item.type {
        case "article":
            // 文章可用 id 或 sourceUrl 兜底
            guard item.id != nil || !item.sourceUrl.isEmpty else { return }
            navigationRoute = .article(
                articleId: item.id,
                sourceId: nil,
                sourceUrl: item.sourceUrl,
                category: ArticleCategory(rawValue: item.category ?? "") ?? .news
            )
        case "directoryItem":
            guard item.id != nil else { return }
            navigationRoute = .directory(
                itemId: item.id,
                sourceId: nil,
                kind: DirectoryItemKind(rawValue: item.kind ?? "") ?? .nationalProject
            )
        case "inheritor":
            guard item.id != nil else { return }
            navigationRoute = .inheritor(
                inheritorId: item.id,
                sourceId: nil
            )
        default:
            break
        }
    }
}

// MARK: - DiscoveryItemDTO 稳定列表 ID

extension DiscoveryItemDTO {
    /// 用于 SwiftUI ForEach 的稳定 ID
    /// 组合 type + id + sourceUrl + title，避免可空或重复字段导致 diff 错乱
    var stableListID: String {
        [
            type,
            id ?? "",
            sourceUrl,
            title,
        ].joined(separator: "|")
    }
}
