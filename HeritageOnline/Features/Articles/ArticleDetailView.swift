import SwiftUI

/// 文章详情页
/// 对齐 Android ArticleDetailScreen
/// Step 11 范围：详情展示 + 图片预览 + 相关文章
struct ArticleDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: ArticleDetailViewModel

    /// 图片预览状态
    @State private var showImagePreview = false
    @State private var previewImageURLs: [String] = []
    @State private var previewIndex = 0

    /// 查看原文错误提示
    @State private var showSourceError = false

    /// 探索区子导航状态
    @State private var navigateToExploreArticle: String?
    @State private var navigateToExploreDirectory: String?
    @State private var navigateToExploreInheritor: String?
    @State private var navigateToExploreCollection: String?
    @State private var navigateToExploreTopic: TopicNavigation?

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news,
        repository: HeritageRepository = DefaultHeritageRepository()
    ) {
        _viewModel = State(initialValue: ArticleDetailViewModel(
            articleId: articleId,
            sourceId: sourceId,
            sourceUrl: sourceUrl,
            category: category,
            repository: repository
        ))
    }

    var body: some View {
        ZStack {
            if viewModel.uiState.isLoading && viewModel.uiState.article == nil {
                LoadingPlaceholder()
            } else if let error = viewModel.uiState.error, viewModel.uiState.article == nil {
                errorView(error)
            } else if let article = viewModel.uiState.article {
                ArticleDetailContent(
                    article: article,
                    isContentStale: viewModel.uiState.isContentStale,
                    isFavorite: viewModel.uiState.isFavorite,
                    // 探索区状态
                    digest: viewModel.uiState.digest,
                    digestLoading: viewModel.uiState.digestLoading,
                    digestError: viewModel.uiState.digestError,
                    context: viewModel.uiState.context,
                    contextLoading: viewModel.uiState.contextLoading,
                    contextError: viewModel.uiState.contextError,
                    blendedRecommendations: viewModel.uiState.blendedRecommendations,
                    onToggleFavorite: { Task { await viewModel.toggleFavorite() } },
                    onOpenSource: { url in
                        openSourceURL(url)
                    },
                    onPreviewImage: { urls, index in
                        previewImageURLs = urls
                        previewIndex = index
                        showImagePreview = true
                    },
                    onRefresh: {
                        Task { await viewModel.refresh() }
                    },
                    onRecordReadingPath: { source, toSourceId, toTitle in
                        Task {
                            await ReadingPathRecorder.shared.record(
                                from: ReadingPathEvent.fromRef(article),
                                toType: .article,
                                toId: toSourceId ?? "",
                                toTitle: toTitle ?? "",
                                source: source,
                                toSourceId: toSourceId
                            )
                        }
                    },
                    onRetryContext: { viewModel.retryContext() },
                    onRetryDigest: { viewModel.retryDigest() },
                    onExploreTargetClick: { click in
                        handleExploreTargetClick(click, from: article)
                    }
                )
            }
        }
        .navigationTitle("articleDetail.title")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        Task { await viewModel.toggleFavorite() }
                    } label: {
                        Image(systemName: viewModel.uiState.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.uiState.isFavorite ? colorScheme.error : colorScheme.onSurfaceVariant)
                    }
                    Button {
                        Task { await viewModel.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
            }
        }
        #endif
        .task {
            await viewModel.refresh()
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showImagePreview) {
            ImagePreviewOverlay(
                imageUrls: previewImageURLs,
                initialIndex: previewIndex,
                onDismiss: { showImagePreview = false }
            )
        }
        #elseif os(macOS)
        .sheet(isPresented: $showImagePreview) {
            ImagePreviewOverlay(
                imageUrls: previewImageURLs,
                initialIndex: previewIndex,
                onDismiss: { showImagePreview = false }
            )
        }
        #endif
        .overlay(alignment: .bottom) {
            if showSourceError {
                sourceErrorSnackbar
            }
        }
        // 探索区子导航
        .navigationDestination(item: $navigateToExploreArticle) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToExploreDirectory) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToExploreInheritor) { id in
            InheritorDetailView(inheritorId: id)
        }
        .navigationDestination(item: $navigateToExploreCollection) { id in
            CollectionDetailView(id: id)
        }
        .navigationDestination(item: $navigateToExploreTopic) { topic in
            ExploreTopicView(type: topic.type, key: topic.key)
        }
    }

    /// 处理探索区目标点击
    private func handleExploreTargetClick(_ click: DetailExploreTargetClick, from article: ArticleDetailDTO) {
        // 先记录阅读路径（异步，不阻塞导航）
        if let toId = click.targetId, let toType = click.targetContentType {
            Task {
                await ReadingPathRecorder.shared.record(
                    from: ReadingPathEvent.fromRef(article),
                    toType: toType,
                    toId: toId,
                    toTitle: click.title ?? "",
                    source: click.source,
                    toCategory: click.category,
                    toKind: click.kind,
                    toSourceId: click.sourceId,
                    toSourceUrl: click.sourceUrl,
                    toImageUrl: click.imageUrl
                )
            }
        }

        // 立即导航
        switch click.target {
        case .article(let id):
            navigateToExploreArticle = id
        case .directoryItem(let id):
            navigateToExploreDirectory = id
        case .inheritor(let id):
            navigateToExploreInheritor = id
        case .collection(let id):
            navigateToExploreCollection = id
        case .topic(let type, let key):
            navigateToExploreTopic = TopicNavigation(type: type, key: key)
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
                Task { await viewModel.refresh() }
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    /// 打开原文链接
    private func openSourceURL(_ urlString: String) {
        guard let url = ExternalURLValidator.httpURL(from: urlString) else {
            showSourceError = true
            return
        }
        #if os(iOS)
        UIApplication.shared.open(url) { success in
            if !success { showSourceError = true }
        }
        #elseif os(macOS)
        if !NSWorkspace.shared.open(url) {
            showSourceError = true
        }
        #endif
    }

    /// 原文打开失败提示
    private var sourceErrorSnackbar: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14))
                .foregroundStyle(colorScheme.onErrorContainer)
            Text("articleDetail.sourceOpenFailed")
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onErrorContainer)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colorScheme.errorContainer)
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onTapGesture { showSourceError = false }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showSourceError = false }
            }
        }
    }
}

// MARK: - 文章详情内容

/// 文章详情内容（无状态）
private struct ArticleDetailContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let article: ArticleDetailDTO
    let isContentStale: Bool
    let isFavorite: Bool
    // 探索区状态
    let digest: ContentDigestDTO?
    let digestLoading: Bool
    let digestError: AppError?
    let context: DetailContextDTO?
    let contextLoading: Bool
    let contextError: AppError?
    let blendedRecommendations: [BlendedRecommendationItemDTO]
    let onToggleFavorite: () -> Void
    let onOpenSource: (String) -> Void
    let onPreviewImage: ([String], Int) -> Void
    let onRefresh: () -> Void
    let onRecordReadingPath: (ReadingPathSource, String?, String?) -> Void
    let onRetryContext: () -> Void
    let onRetryDigest: () -> Void
    let onExploreTargetClick: (DetailExploreTargetClick) -> Void

    /// 收集所有可预览图片 URL
    private var previewURLs: [String] {
        ImagePreviewUrl.collect(
            coverImage: article.coverImage,
            gallery: [],
            contentBlocks: article.contentBlocks
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // 过期内容提示
                if isContentStale {
                    staleContentBanner
                }

                // Hero 区
                ArticleHero(
                    article: article,
                    onOpenSource: onOpenSource,
                    onPreviewCover: {
                        if !previewURLs.isEmpty {
                            onPreviewImage(previewURLs, 0)
                        }
                    }
                )

                // 摘要
                if let summary = article.summary, !summary.isEmpty {
                    Text(summary)
                        .font(HeritageTypography.bodyLarge)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineSpacing(6)
                }

                // Content Blocks
                if !article.contentBlocks.isEmpty {
                    ForEach(Array(article.contentBlocks.enumerated()), id: \.offset) { blockIndex, block in
                        let imageStartIndex = (article.coverImage != nil ? 1 : 0)
                        let imageBlockIndex = imageStartIndex + article.contentBlocks.prefix(blockIndex).filter { $0.type == .image }.count
                        DetailContentBlockView(
                            block: block,
                            previewURLs: previewURLs,
                            imageIndex: block.type == .image ? imageBlockIndex : nil,
                            onPreviewImage: onPreviewImage
                        )
                    }
                } else if article.summary == nil || article.summary?.isEmpty == true {
                    // 空内容兜底
                    Text("articleDetail.emptyContent")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                }

                // 相关文章
                if !article.relatedArticles.isEmpty {
                    SectionHeader(title: String(localized: "articleDetail.relatedArticles"))
                    ForEach(Array(article.relatedArticles.enumerated()), id: \.offset) { _, reference in
                        RelatedArticleRow(reference: reference) {
                            onRecordReadingPath(.related, reference.sourceId, reference.title)
                        }
                    }
                }

                // 底部探索区
                DetailExploreSection(
                    digest: digest,
                    digestLoading: digestLoading,
                    digestError: digestError,
                    onDigestRetry: onRetryDigest,
                    blendedRecommendations: blendedRecommendations,
                    context: context,
                    contextLoading: contextLoading,
                    contextError: contextError,
                    onContextRetry: onRetryContext,
                    onExploreTargetClick: onExploreTargetClick
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(colorScheme.background)
    }

    /// 过期内容提示
    private var staleContentBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14))
                .foregroundStyle(colorScheme.onTertiaryContainer)
            Text("articleDetail.staleContent")
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onTertiaryContainer)
            Spacer()
            Button("action.refresh") {
                onRefresh()
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.tertiary)
        }
        .padding(12)
        .background(colorScheme.tertiaryContainer)
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }
}

// MARK: - Topic Navigation Helper

/// 主题导航辅助结构体（Hashable）
struct TopicNavigation: Hashable {
    let type: String
    let key: String
}

// MARK: - 文章 Hero 区

/// 文章详情 Hero 区：封面图 + 分类 chip + 标题 + 元信息 + 查看原文
private struct ArticleHero: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let article: ArticleDetailDTO
    let onOpenSource: (String) -> Void
    let onPreviewCover: () -> Void

    /// 本地化 category
    private var categoryLabel: String? {
        guard let key = ContentLabels.localizedArticleCategory(article.category) else { return nil }
        return String(localized: String.LocalizationValue(key))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 分类 chip
            if let categoryLabel {
                MetaChip(categoryLabel)
            }

            // 标题
            if let title = article.title, !title.isEmpty {
                Text(title)
                    .font(HeritageTypography.headlineMedium)
                    .foregroundStyle(colorScheme.onSurface)
            }

            // 元信息：日期、作者、编辑、来源
            ArticleMetaChips(article: article)

            // 查看原文按钮
            if let sourceUrl = article.sourceUrl, !sourceUrl.isEmpty {
                Button {
                    onOpenSource(sourceUrl)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 14))
                        Text("articleDetail.viewSource")
                            .font(HeritageTypography.labelLarge)
                    }
                    .foregroundStyle(colorScheme.primary)
                }
                .buttonStyle(.plain)
            }

            // 封面图
            if let coverImage = article.coverImage {
                let urlString = ImagePreviewUrl.previewUrl(from: coverImage)
                HeritageDetailImage(
                    urlString: urlString,
                    placeholderText: article.title ?? "E",
                    contentMode: .fit,
                    onTap: onPreviewCover
                )
                .aspectRatio(4/3, contentMode: .fit)
            }
        }
    }
}

// MARK: - 文章元信息 chips

/// 文章元信息：日期、作者、编辑、来源
private struct ArticleMetaChips: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let article: ArticleDetailDTO

    var body: some View {
        FlowLayout(spacing: 6) {
            if let date = DateDisplayFormatter.displayDate(from: article.publishedAt) {
                MetaChip(date)
            }
            if let author = article.author, !author.isEmpty {
                MetaChip(author)
            }
            if let editor = article.editor, !editor.isEmpty {
                MetaChip(editor)
            }
            if let sourceName = article.sourceName, !sourceName.isEmpty {
                MetaChip(sourceName)
            }
        }
    }
}

// MARK: - Preview

/// 相关文章卡片
private struct RelatedArticleRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let reference: ArticleReferenceDTO
    let onNavigate: () -> Void

    /// 构建导航目标
    private var hasTarget: Bool {
        (reference.sourceId != nil && !(reference.sourceId?.isEmpty ?? true))
            || (reference.detailUrl != nil && !(reference.detailUrl?.isEmpty ?? true))
    }

    var body: some View {
        if hasTarget {
            NavigationLink {
                ArticleDetailView(
                    sourceId: reference.sourceId,
                    sourceUrl: reference.detailUrl
                )
            } label: {
                referenceCardContent
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                onNavigate()
            })
        } else {
            referenceCardContent
        }
    }

    private var referenceCardContent: some View {
        ContentCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = reference.title, !title.isEmpty {
                        Text(title)
                            .font(HeritageTypography.titleMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(2)
                    }
                    if let date = DateDisplayFormatter.displayDate(from: reference.publishedAt) {
                        Text(date)
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(14)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ArticleDetailView(articleId: "test")
    }
    .environment(SettingsManager.shared)
    .heritageTheme()
}
