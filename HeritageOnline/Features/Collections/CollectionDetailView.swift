import SwiftUI

/// 合集详情页
/// 对齐 Android CollectionScreen / CollectionRoute
/// 展示合集标题、元数据 chips、混合内容项列表
struct CollectionDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: CollectionDetailViewModel

    /// 子导航状态
    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?

    /// 按 id 初始化（精选合集 / 固定合集）
    init(id: String) {
        _viewModel = State(initialValue: CollectionDetailViewModel(id: id))
    }

    /// 按 type + key 初始化（主题合集）
    init(type: String, key: String) {
        _viewModel = State(initialValue: CollectionDetailViewModel(type: type, key: key))
    }

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.isLoading && viewModel.collection == nil {
                    LoadingPlaceholder()
                } else if let error = viewModel.error, viewModel.collection == nil {
                    CollectionErrorContent(
                        error: error,
                        onRetry: { viewModel.loadCollection() }
                    )
                } else if let collection = viewModel.collection {
                    CollectionContent(
                        collection: collection,
                        onItemClick: { item in
                            handleItemClick(item)
                        }
                    )
                }
            }
        }
        .navigationTitle(viewModel.collection?.title ?? String(localized: "contentType.collection"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadCollection()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.collection == nil && viewModel.error == nil {
                viewModel.loadCollection()
            }
        }
        // 子导航
        .navigationDestination(item: $navigateToArticle) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToDirectory) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToInheritor) { id in
            InheritorDetailView(inheritorId: id)
        }
    }

    /// 处理内容项点击
    private func handleItemClick(_ item: CollectionItemDTO) {
        guard let id = item.id, !id.isEmpty else { return }
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

// MARK: - 合集内容

/// 合集内容（无状态）
private struct CollectionContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let collection: CollectionDTO
    let onItemClick: (CollectionItemDTO) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                // 标题和副标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.title ?? "")
                        .font(HeritageTypography.headlineMedium)
                        .foregroundStyle(colorScheme.onSurface)

                    if let subtitle = collection.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyLarge)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
                .padding(.horizontal, 20)

                // 元数据 chips
                CollectionMetaChips(collection: collection)
                    .padding(.horizontal, 20)

                // 条目数量
                Text(String(format: String(localized: "search.resultsCount"), collection.items.count))
                    .font(HeritageTypography.labelLarge)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .padding(.horizontal, 20)

                if collection.items.isEmpty {
                    // 空合集
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                        Text(String(localized: "empty.noContent"))
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    // 内容项列表
                    ForEach(Array(collection.items.enumerated()), id: \.offset) { _, item in
                        CollectionItemRow(
                            item: item,
                            onClick: { onItemClick(item) }
                        )
                    }
                    .padding(.horizontal, 20)
                }

                // 底部间距
                Spacer()
                    .frame(height: 18)
            }
            .padding(.vertical, 18)
        }
    }
}

// MARK: - 元数据 Chips

/// 合集元数据 chips（type、tags、generatedAt）
private struct CollectionMetaChips: View {
    let collection: CollectionDTO

    var body: some View {
        FlowLayout(spacing: 8) {
            if let type = collection.type, !type.isEmpty {
                MetaChip(type)
            }
            ForEach(Array(collection.tags.enumerated()), id: \.offset) { _, tag in
                MetaChip(tag)
            }
            if let generatedAt = collection.generatedAt, !generatedAt.isEmpty {
                MetaChip(generatedAt)
            }
        }
    }
}

// MARK: - 合集项行

/// 合集内容项卡片
/// 对齐 Android CollectionItemRow
private struct CollectionItemRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: CollectionItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 6) {
                // 类型和分类 chips
                HStack(spacing: 8) {
                    let typeLabel = LocalizedStringKey(ContentLabels.contentTypeKey(item.type))
                    MetaChip(typeLabel)

                    if let category = item.category, !category.isEmpty {
                        if let categoryKey = ContentLabels.articleCategoryKey(category) {
                            MetaChip(LocalizedStringKey(categoryKey))
                        } else {
                            MetaChip(category)
                        }
                    }
                }

                // 标题
                Text(item.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                // 摘要
                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                }

                // 地区和年份
                HStack(spacing: 12) {
                    if let region = item.region, !region.isEmpty {
                        Text(region)
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                    if let publishedYear = item.publishedYear {
                        Text(String(format: String(localized: "directory.yearFormat"), publishedYear))
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 错误内容

/// 合集加载错误视图
private struct CollectionErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button("action.retry") {
                onRetry()
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CollectionDetailView(id: "latest-news")
    }
    .heritageTheme()
}
