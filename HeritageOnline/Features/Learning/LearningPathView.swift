import SwiftUI

/// 学习路径详情页
/// 对齐 Android LearningPathScreen
/// 展示标题、标签、步骤、精选内容、相关主题
struct LearningPathView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: LearningPathViewModel

    /// 子导航状态
    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?
    @State private var navigateToRelatedTopic: ExploreTopicLinkDTO?

    init(id: String) {
        _viewModel = State(initialValue: LearningPathViewModel(id: id))
    }

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.isLoading && viewModel.path == nil {
                    LoadingPlaceholder()
                } else if let error = viewModel.error, viewModel.path == nil {
                    errorView(error)
                } else if let path = viewModel.path {
                    LearningPathContent(
                        path: path,
                        onItemClick: { item in
                            handleItemClick(item)
                        },
                        onRelatedTopicClick: { link in
                            navigateToRelatedTopic = link
                        }
                    )
                }
            }
        }
        .navigationTitle(viewModel.path?.title ?? String(localized: "discovery.learningPaths"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadPath()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.path == nil && viewModel.error == nil {
                viewModel.loadPath()
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
        .navigationDestination(item: $navigateToRelatedTopic) { link in
            if let type = link.type, let key = link.key {
                ExploreTopicView(type: type, key: key)
            }
        }
    }

    /// 处理内容项点击
    private func handleItemClick(_ item: ExploreTopicItemDTO) {
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

    /// 错误视图
    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button("action.retry") {
                viewModel.loadPath()
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - 学习路径内容

/// 学习路径内容（无状态）
private struct LearningPathContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let path: LearningPathDetailDTO
    let onItemClick: (ExploreTopicItemDTO) -> Void
    let onRelatedTopicClick: (ExploreTopicLinkDTO) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // 标题和副标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(path.title ?? "")
                        .font(HeritageTypography.headlineMedium)
                        .foregroundStyle(colorScheme.onSurface)

                    if let subtitle = path.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyLarge)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
                .padding(.horizontal, 20)

                // 描述
                if let description = path.description, !description.isEmpty {
                    Text(description)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .padding(.horizontal, 20)
                }

                // 标签
                if !path.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(Array(path.tags.enumerated()), id: \.offset) { _, tag in
                            MetaChip(tag)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 步骤
                if !path.steps.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: String(localized: "learning.steps"))

                        ForEach(Array(path.steps.enumerated()), id: \.offset) { index, step in
                            LearningStepCard(
                                stepNumber: index + 1,
                                step: step,
                                isLast: index == path.steps.count - 1,
                                onItemClick: onItemClick
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 精选内容
                if !path.featuredItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "learning.featuredItems"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(path.featuredItems.enumerated()), id: \.offset) { _, item in
                                    FeaturedItemCard(item: item) {
                                        onItemClick(item)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                // 相关主题
                if !path.relatedTopics.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "context.exploreTopics"))

                        FlowLayout(spacing: 8) {
                            ForEach(Array(path.relatedTopics.enumerated()), id: \.offset) { _, link in
                                Button {
                                    onRelatedTopicClick(link)
                                } label: {
                                    MetaChip(link.title ?? link.key ?? "")
                                }
                                .buttonStyle(.plain)
                            }
                        }
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

// MARK: - 学习步骤卡片

/// 学习步骤卡片（纵向 stepper 风格）
private struct LearningStepCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let stepNumber: Int
    let step: LearningPathStepDTO
    let isLast: Bool
    let onItemClick: (ExploreTopicItemDTO) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 左侧序号和连接线
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(colorScheme.primaryContainer)
                        .frame(width: 32, height: 28)

                    Text("\(stepNumber)")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onPrimaryContainer)
                }

                if !isLast {
                    Rectangle()
                        .fill(colorScheme.outlineVariant)
                        .frame(width: 2, height: 20)
                }
            }
            .frame(width: 32)

            // 右侧内容
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)

                    if let subtitle = step.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(3)
                    }
                }

                // 步骤内的内容项
                if !step.items.isEmpty {
                    VStack(spacing: 6) {
                        ForEach(Array(step.items.enumerated()), id: \.offset) { _, item in
                            StepItemRow(item: item) {
                                onItemClick(item)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 步骤项行

/// 步骤内的内容项行
private struct StepItemRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: ExploreTopicItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 10) {
                // 小圆点
                Circle()
                    .fill(colorScheme.tertiaryContainer)
                    .frame(width: 8, height: 8)

                Text(item.title ?? "")
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurface)
                    .lineLimit(1)

                Spacer()

                if let category = item.category, !category.isEmpty {
                    MetaChip(LocalizedStringKey(ContentLabels.articleCategoryKey(category) ?? category))
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 精选内容卡片

/// 学习路径精选内容卡片
private struct FeaturedItemCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: ExploreTopicItemDTO
    let onClick: () -> Void

    /// 获取最佳图片 URL
    private var bestImageUrl: String? {
        item.coverImage?.displayUrl ?? item.coverImage?.thumbnailUrl ?? item.coverImage?.originalUrl ?? item.coverImage?.sourceUrl
    }

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 0) {
                // 图片区域
                if let imageUrl = bestImageUrl {
                    HeritageAsyncImage(
                        urlString: imageUrl,
                        placeholderText: String((item.title ?? "").prefix(1))
                    )
                    .frame(height: 100)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                } else {
                    ZStack {
                        colorScheme.surfaceContainerHighest
                        Text(String((item.title ?? "").prefix(1)))
                            .font(HeritageTypography.headlineMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                    .frame(height: 100)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 8, topTrailingRadius: 8))
                }

                // 文字区域
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundStyle(colorScheme.onSurface)

                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }
                }
                .padding(10)
            }
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .frame(width: 180)
    }
}

#Preview {
    NavigationStack {
        LearningPathView(id: "sample-path")
    }
    .heritageTheme()
}
