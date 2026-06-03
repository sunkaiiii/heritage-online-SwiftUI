import SwiftUI

/// 文章详情页
/// 对齐 Android ArticleDetailScreen
/// Step 11 范围：详情展示 + 图片预览 + 相关文章
struct ArticleDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ArticleDetailViewModel

    /// 图片预览状态
    @State private var showImagePreview = false
    @State private var previewImageURLs: [String] = []
    @State private var previewIndex = 0

    /// 查看原文错误提示
    @State private var showSourceError = false

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
                    onToggleFavorite: { viewModel.toggleFavorite() },
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
                    }
                )
            }
        }
        .navigationTitle("articleDetail.title")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(colorScheme.onSurface)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.toggleFavorite()
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
    let onToggleFavorite: () -> Void
    let onOpenSource: (String) -> Void
    let onPreviewImage: ([String], Int) -> Void
    let onRefresh: () -> Void

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
                    ForEach(Array(article.contentBlocks.enumerated()), id: \.offset) { index, block in
                        ContentBlockView(
                            block: block,
                            previewURLs: previewURLs,
                            coverImageURL: ImagePreviewUrl.previewUrl(from: article.coverImage),
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
                        RelatedArticleRow(reference: reference)
                    }
                }
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
            if let date = article.publishedAt, !date.isEmpty {
                MetaChip(formatDate(date))
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

    /// 简单日期格式化
    private func formatDate(_ value: String) -> String {
        // 尝试 ISO 8601
        if let date = ISO8601DateFormatter().date(from: value) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
            return formatter.string(from: date)
        }
        // 尝试 yyyy-MM-dd
        if value.count >= 10 {
            return String(value.prefix(10))
        }
        return value
    }
}

// MARK: - 内容块视图

/// 渲染单个 contentBlock
private struct ContentBlockView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let block: ArticleContentBlockDTO
    let previewURLs: [String]
    let coverImageURL: String?
    let onPreviewImage: ([String], Int) -> Void

    var body: some View {
        switch block.type {
        case .heading:
            if let text = block.text, !text.isEmpty {
                SectionHeader(title: text)
            }

        case .text:
            if let text = block.text, !text.isEmpty {
                if isStandaloneSectionTitle(text) {
                    Text(text)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                } else {
                    Text(text)
                        .font(HeritageTypography.bodyLarge)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineSpacing(6)
                }
            }

        case .image:
            if let image = block.image {
                let urlString = ImagePreviewUrl.previewUrl(from: image)
                HeritageDetailImage(
                    urlString: urlString,
                    placeholderText: "E",
                    contentMode: .fit,
                    onTap: {
                        // 计算当前图片在 previewURLs 中的索引
                        if let urlString, let idx = previewURLs.firstIndex(of: urlString) {
                            onPreviewImage(previewURLs, idx)
                        }
                    }
                )
                .aspectRatio(4/3, contentMode: .fit)
            }
        }
    }

    /// 判断是否为独立短标题
    /// 对齐 Android isStandaloneSectionTitle
    private func isStandaloneSectionTitle(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        // 以冒号结尾
        if trimmed.hasSuffix("：") || trimmed.hasSuffix(":") {
            return trimmed.count <= 32
        }
        // 无句末标点且短
        let sentenceEnders: [Character] = ["。", "！", "？", ".", "!", "?", "；", ";"]
        let hasSentenceEnder = trimmed.contains(where: { sentenceEnders.contains($0) })
        return !hasSentenceEnder && trimmed.count <= 18
    }
}

// MARK: - 相关文章行

/// 相关文章卡片
private struct RelatedArticleRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let reference: ArticleReferenceDTO

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
                    if let date = reference.publishedAt, !date.isEmpty {
                        Text(formatDate(date))
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

    private func formatDate(_ value: String) -> String {
        if value.count >= 10 {
            return String(value.prefix(10))
        }
        return value
    }
}

// MARK: - FlowLayout

/// 横向流式布局，用于元信息 chips
private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
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
