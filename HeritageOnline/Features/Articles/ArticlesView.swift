import SwiftUI

/// 文章列表视图
/// 对齐 Android ArticlesScreen / ArticlesRoute
/// 完整实现：Banner、搜索、分类、筛选、分页列表
struct ArticlesView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let onSettingsSelected: () -> Void

    /// ViewModel
    @State private var viewModel: ArticlesViewModel

    /// 是否显示筛选 sheet
    @State private var showFilterSheet = false

    /// 图片预览状态
    @State private var previewImageURLs: [String] = []
    @State private var previewIndex: Int = 0
    @State private var showImagePreview = false

    init(
        repository: HeritageRepository = DefaultHeritageRepository(),
        onSettingsSelected: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: ArticlesViewModel(repository: repository))
        self.onSettingsSelected = onSettingsSelected
    }

    var body: some View {
        ArticlesContent(
            viewModel: viewModel,
            onSettingsSelected: onSettingsSelected,
            showFilterSheet: $showFilterSheet,
            onBannerTap: { url in
                if let url = ExternalURLValidator.httpURL(from: url) {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #elseif os(macOS)
                    NSWorkspace.shared.open(url)
                    #endif
                }
            },
            onImagePreview: { urls, index in
                previewImageURLs = urls
                previewIndex = index
                showImagePreview = true
            }
        )
        .sheet(isPresented: $showFilterSheet) {
            ArticleFilterSheet(
                yearFilter: viewModel.uiState.yearFilter,
                onApply: { year in
                    showFilterSheet = false
                    Task { await viewModel.applyYearFilter(year) }
                },
                onClear: {
                    showFilterSheet = false
                    Task { await viewModel.clearYearFilter() }
                },
                onDismiss: {
                    showFilterSheet = false
                }
            )
            .presentationDetents([.medium])
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
        .task {
            await viewModel.refresh()
        }
    }
}

// MARK: - 文章列表内容

/// 文章列表内容（无状态）
private struct ArticlesContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let viewModel: ArticlesViewModel
    let onSettingsSelected: () -> Void
    @Binding var showFilterSheet: Bool
    let onBannerTap: (String) -> Void
    let onImagePreview: ([String], Int) -> Void

    var body: some View {
        PageBackground {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // MARK: - 页面头部
                    articlesHeader

                    // MARK: - Banner 区
                    bannerSection

                    // MARK: - 区块标题
                    SectionHeader(title: String(localized: "articles.latest"))

                    // MARK: - 搜索框
                    searchSection

                    // MARK: - 活跃筛选 chips
                    if !viewModel.uiState.yearFilter.trimmingCharacters(in: .whitespaces).isEmpty {
                        activeFilterChips
                    }

                    // MARK: - 校验错误提示
                    if let validationError = viewModel.uiState.validationError {
                        validationBanner(validationError)
                    }

                    // MARK: - 分类 tabs
                    categoryTabs

                    // MARK: - 文章列表内容
                    articlesListContent
                }
                .padding(.bottom, 18)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - 页面头部

    private var articlesHeader: some View {
        PageHeader(
            titleKey: "app.name",
            subtitleKey: "page.articles.subtitle",
            actions: [
                .init(icon: "line.3.horizontal.decrease.circle", accessibilityLabelKey: "nav.filter") {
                    showFilterSheet = true
                },
                .init(icon: "gear", accessibilityLabelKey: "nav.settings") {
                    onSettingsSelected()
                },
                .init(icon: "arrow.clockwise", accessibilityLabelKey: "action.refresh") {
                    Task { await viewModel.refresh() }
                }
            ]
        )
    }

    // MARK: - Banner 区

    private var bannerSection: some View {
        Group {
            if viewModel.uiState.isLoadingBanners {
                bannerLoadingPlaceholder
            } else if let error = viewModel.uiState.bannerError {
                bannerErrorView(error)
            } else if !viewModel.uiState.banners.isEmpty {
                bannerStrip
            }
        }
    }

    /// Banner 横向滚动条
    private var bannerStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.uiState.banners, id: \.id) { banner in
                    BannerCard(banner: banner, onTap: onBannerTap)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }

    /// Banner 加载占位
    private var bannerLoadingPlaceholder: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius)
                        .fill(colorScheme.surfaceContainerHigh)
                        .frame(width: 300, height: 156)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
    }

    /// Banner 错误视图
    private func bannerErrorView(_ error: AppError) -> some View {
        ErrorRetryRow(message: error.localizedDescription) {
            Task { await viewModel.loadBanners() }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    // MARK: - 搜索区

    private var searchSection: some View {
        SearchField(
            text: Binding(
                get: { viewModel.uiState.searchKeywords },
                set: { viewModel.updateSearchKeywords($0) }
            ),
            placeholder: "articles.searchPlaceholder"
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - 活跃筛选 chips

    private var activeFilterChips: some View {
        HStack(spacing: 8) {
            let yearText = viewModel.uiState.yearFilter.trimmingCharacters(in: .whitespaces)
            if !yearText.isEmpty {
                HStack(spacing: 4) {
                    Text("\(String(localized: "articles.filter.year")): \(yearText)")
                        .font(HeritageTypography.labelLarge)
                        .foregroundStyle(colorScheme.onPrimaryContainer)

                    Button {
                        Task { await viewModel.clearYearFilter() }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(colorScheme.onPrimaryContainer)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(colorScheme.primaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    /// 校验错误提示（不隐藏列表）
    private func validationBanner(_ error: AppError) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 14))
                .foregroundStyle(colorScheme.onErrorContainer)
            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onErrorContainer)
            Spacer()
            Button {
                viewModel.dismissValidationError()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(colorScheme.onErrorContainer)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(colorScheme.errorContainer)
        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - 分类 tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(ArticleCategory.allCases, id: \.self) { category in
                    let key = ContentLabels.localizedArticleCategory(category.wireName) ?? category.wireName
                    let label = String(localized: String.LocalizationValue(key))
                    let isSelected = viewModel.uiState.selectedCategory == category

                    Button {
                        viewModel.selectCategory(category)
                    } label: {
                        MetaChip(label, isSelected: isSelected)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
    }

    // MARK: - 文章列表

    @ViewBuilder
    private var articlesListContent: some View {
        if viewModel.uiState.isLoading {
            // 首屏加载
            ListLoadingPlaceholder(count: 5)
                .padding(.horizontal, 20)
        } else if let error = viewModel.uiState.error {
            // 首屏错误
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(colorScheme.onSurfaceVariant)

                Text(verbatim: error.localizedDescription)
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)

                Button("action.retry") {
                    Task { await viewModel.loadArticles() }
                }
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
        } else if viewModel.uiState.articles.isEmpty {
            // 空状态
            let isSearching = !viewModel.uiState.searchKeywords.trimmingCharacters(in: .whitespaces).isEmpty
                || !viewModel.uiState.yearFilter.trimmingCharacters(in: .whitespaces).isEmpty

            EmptyState(
                icon: isSearching ? "doc.text.magnifyingglass" : "tray",
                title: isSearching ? "articles.empty.search" : "articles.empty.default",
                message: isSearching ? "articles.empty.searchHint" : nil
            )
            .frame(minHeight: 300)
        } else {
            // 文章列表
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.uiState.articles.enumerated()), id: \.offset) { index, article in
                    ArticleRow(
                        article: article,
                        isProminent: index == 0,
                        onImagePreview: onImagePreview
                    )
                }

                // 分页 sentinel（不可见触发器）
                if viewModel.uiState.hasMore {
                    Color.clear
                        .frame(height: 1)
                        .task(id: viewModel.uiState.articles.count) {
                            await viewModel.loadMore()
                        }
                }

                // 追加加载状态
                if viewModel.uiState.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(colorScheme.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // 追加错误
                if let appendError = viewModel.uiState.appendError {
                    ErrorRetryRow(message: appendError.localizedDescription) {
                        Task { await viewModel.loadMore() }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - 文章行

/// 单个文章卡片
private struct ArticleRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let article: ArticleSummaryDTO
    let isProminent: Bool
    let onImagePreview: ([String], Int) -> Void

    var body: some View {
        let imageURL = ImagePreviewUrl.listUrl(from: article.coverImage)
        // 本地化 category：将 key 转为本地化显示文本
        let categoryLabel: String? = {
            guard let key = ContentLabels.localizedArticleCategory(article.category) else { return nil }
            return String(localized: String.LocalizationValue(key))
        }()

        NavigationLink(destination: ArticleDetailView(
            articleId: article.id,
            sourceId: nil,
            sourceUrl: article.sourceUrl,
            category: ArticleCategory(rawValue: article.category ?? "news") ?? .news
        )) {
            ListCard(
                title: article.title ?? "",
                subtitle: nil,
                summary: article.summary,
                imageURL: imageURL.flatMap { URL(string: $0) },
                category: categoryLabel,
                date: DateDisplayFormatter.displayDate(from: article.publishedAt),
                isProminent: isProminent
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Banner 卡片

/// Banner 横向卡片
private struct BannerCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let banner: HomeBannerDTO
    let onTap: (String) -> Void

    /// Banner 图片 URL 选择
    /// 完全对齐 Android 优先级：
    /// mobile.displayUrl > mobile.thumbnailUrl > mobile.originalUrl > mobile.sourceUrl
    /// > displayImage.displayUrl > displayImage.thumbnailUrl > ...
    /// > desktopImage.displayUrl > desktopImage.thumbnailUrl > ...
    private var imageURL: String? {
        // 按 Android 优先级收集所有候选 URL
        let candidates: [String?] = [
            banner.mobileImage?.displayUrl,
            banner.mobileImage?.thumbnailUrl,
            banner.mobileImage?.originalUrl,
            banner.mobileImage?.sourceUrl,
            banner.displayImage?.displayUrl,
            banner.displayImage?.thumbnailUrl,
            banner.displayImage?.originalUrl,
            banner.displayImage?.sourceUrl,
            banner.desktopImage?.displayUrl,
            banner.desktopImage?.thumbnailUrl,
            banner.desktopImage?.originalUrl,
            banner.desktopImage?.sourceUrl,
        ]
        return candidates.compactMap { $0 }.first { !$0.isEmpty }
    }

    var body: some View {
        Button {
            if let targetUrl = banner.targetUrl {
                onTap(targetUrl)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius)
                    .fill(colorScheme.surfaceContainerHigh)

                if let imageURL, let url = Self.validURL(from: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            bannerPlaceholder
                        case .empty:
                            ProgressView()
                                .tint(colorScheme.primary)
                        @unknown default:
                            bannerPlaceholder
                        }
                    }
                } else {
                    bannerPlaceholder
                }
            }
            .frame(width: 300, height: 156)
            .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    private var bannerPlaceholder: some View {
        ZStack {
            colorScheme.surfaceContainerHigh
            Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundStyle(colorScheme.onSurfaceVariant.opacity(0.5))
        }
    }

    /// 清洗并验证 URL：trim 空白、尝试 percent-encoding 修复含空格等字符的 URL
    private static func validURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        // 直接解析
        if let url = URL(string: trimmed) {
            return url
        }
        // 尝试 percent-encoding 后解析
        if let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encoded) {
            return url
        }
        return nil
    }
}

// MARK: - 筛选 Sheet

/// 文章年份筛选底部弹层
private struct ArticleFilterSheet: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let yearFilter: String
    let onApply: (String) -> Void
    let onClear: () -> Void
    let onDismiss: () -> Void

    @State private var yearText: String = ""
    @State private var validationError: String? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // 年份输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("articles.filter.year")
                        .font(HeritageTypography.titleMedium)
                        .foregroundStyle(colorScheme.onSurface)

                    TextField("articles.filter.yearPlaceholder", text: $yearText)
                        .font(HeritageTypography.bodyMedium)
                        .textFieldStyle(.roundedBorder)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .onChange(of: yearText) { _, _ in
                            validationError = nil
                        }

                    if let validationError {
                        Text(validationError)
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.error)
                    }
                }

                // 按钮
                HStack(spacing: 12) {
                    Button("action.clear") {
                        onClear()
                    }
                    .font(HeritageTypography.labelLarge)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(colorScheme.surfaceContainerHigh)
                    .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))

                    Button("action.apply") {
                        validateAndApply()
                    }
                    .font(HeritageTypography.labelLarge)
                    .foregroundStyle(colorScheme.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(colorScheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                }

                Spacer()
            }
            .padding(20)
            .background(colorScheme.background)
            .navigationTitle("nav.filter")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("nav.cancel") {
                        onDismiss()
                    }
                }
            }
            #endif
        }
        .onAppear {
            yearText = yearFilter
        }
    }

    private func validateAndApply() {
        let trimmed = yearText.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            onApply("")
            return
        }
        guard YearFilterValidator.isValidYear(trimmed) else {
            validationError = String(localized: "filter.invalidYear")
            return
        }
        onApply(trimmed)
    }
}

// MARK: - ArticleCategory CaseIterable

extension ArticleCategory: CaseIterable {
    public static var allCases: [ArticleCategory] = [.news, .forum, .specialTopic]
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ArticlesView(onSettingsSelected: {})
    }
    .environment(SettingsManager.shared)
    .heritageTheme()
}
