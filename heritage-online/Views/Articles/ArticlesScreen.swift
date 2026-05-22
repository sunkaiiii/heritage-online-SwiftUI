import SwiftUI

struct ArticlesScreen: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var navigationPath: NavigationPath
    var onSettings: (() -> Void)? = nil
    @State private var viewModel = ArticlesViewModel()
    @State private var showFilterSheet = false
    @State private var scrollID: String?
    @State private var draftYearFilter = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerSection
                bannerSection
                sectionHeader
                searchField
                yearFilterChip
                categoryTabs
                contentSection
            }
            .padding(.bottom, 18)
        }
        .scrollPosition(id: $scrollID)
        .background(theme.background)
        .task {
            await viewModel.loadBanners()
            await viewModel.loadArticles()
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            Task { await viewModel.loadArticles() }
        }
        .onChange(of: viewModel.searchKeywords) { _, _ in
            Task { await viewModel.loadArticles() }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheetView
                .presentationDetents([.medium])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            HeritagePageHeader(
                title: loc.localized("articles_header_title"),
                subtitle: loc.localized("articles_header_subtitle")
            )
            Spacer()
            HStack(spacing: 8) {
                HeritageFilterButton(
                    activeFilterCount: viewModel.yearFilter.isEmpty ? 0 : 1,
                    action: { showFilterSheet = true }
                )
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding(.trailing, 20)
        }
    }

    // MARK: - Banner Strip

    @ViewBuilder
    private var bannerSection: some View {
        if viewModel.isLoadingBanners && viewModel.banners.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.surfaceContainerHigh)
                            .frame(width: 300, height: 156)
                    }
                }
                .padding(.horizontal, 20)
            }
        } else if let bannerError = viewModel.bannerError, viewModel.banners.isEmpty {
            InlineRetryMessage(message: bannerError) {
                Task { await viewModel.loadBanners() }
            }
        } else if !viewModel.banners.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.banners.enumerated()), id: \.offset) { _, banner in
                        BannerCard(banner: banner)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HeritageSectionHeader(title: loc.localized("articles_latest_title"))
    }

    // MARK: - Search Field

    private var searchField: some View {
        HeritageSearchField(
            text: $viewModel.searchKeywords,
            placeholder: loc.localized("articles_search_placeholder")
        )
    }

    // MARK: - Year Filter Chip

    @ViewBuilder
    private var yearFilterChip: some View {
        if !viewModel.yearFilter.isEmpty {
            HStack {
                HeritageMetaChip(text: loc.localized("filter_field_year") + ": " + viewModel.yearFilter)
                Button {
                    viewModel.yearFilter = ""
                    Task { await viewModel.loadArticles() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ArticleCategory.allCases, id: \.self) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        Text(category.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedCategory == category
                                    ? theme.primaryContainer
                                    : theme.surfaceContainerHigh
                            )
                            .foregroundColor(
                                viewModel.selectedCategory == category
                                    ? theme.onPrimaryContainer
                                    : theme.onSurfaceVariant
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoadingArticles {
            LoadingContent()
        } else if let error = viewModel.articleError {
            ErrorContent(message: error) {
                Task { await viewModel.loadArticles() }
            }
        } else if viewModel.articles.isEmpty {
            let emptyMessage = viewModel.searchKeywords.isEmpty
                ? loc.localized("home_empty_message")
                : loc.localized("articles_search_empty_message")
            EmptyContent(message: emptyMessage) {
                Task { await viewModel.loadArticles() }
            }
        } else {
            if horizontalSizeClass == .regular {
            let columns = [GridItem(.adaptive(minimum: 350))]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                    ArticleRow(article: article, prominent: false) {
                        navigationPath.append(ArticleNavigationDestination.articleDetail(id: article.id, sourceId: nil, sourceUrl: article.sourceUrl, category: article.category))
                    }
                        .onAppear {
                            if index == viewModel.articles.count - 3 {
                                Task { await viewModel.loadMoreArticles() }
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            } else {
            ForEach(Array(viewModel.articles.enumerated()), id: \.element.id) { index, article in
                ArticleRow(article: article, prominent: index == 0) {
                    navigationPath.append(ArticleNavigationDestination.articleDetail(id: article.id, sourceId: nil, sourceUrl: article.sourceUrl, category: article.category))
                }
                    .padding(.horizontal, 20)
                    .onAppear {
                        if index == viewModel.articles.count - 3 {
                            Task { await viewModel.loadMoreArticles() }
                        }
                    }
            }
            }

            if viewModel.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Filter Sheet

    private var filterSheetView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(loc.localized("filter_title"))
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 8) {
                Text(loc.localized("filter_field_year"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(loc.localized("filter_placeholder_year"), text: $draftYearFilter)
                    .textFieldStyle(.roundedBorder)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
            }

            HStack {
                Button("filter_clear") {
                    viewModel.yearFilter = ""
                    draftYearFilter = ""
                    showFilterSheet = false
                    Task { await viewModel.loadArticles() }
                }
                Spacer()
                Button("filter_apply") {
                    viewModel.yearFilter = draftYearFilter
                    showFilterSheet = false
                    Task { await viewModel.loadArticles() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(draftYearFilter.count != 4 && !draftYearFilter.isEmpty)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .onAppear {
            draftYearFilter = viewModel.yearFilter
        }
    }
}

// MARK: - Banner Card

struct BannerCard: View {
    @Environment(LocalizationManager.self) private var loc
    let banner: HomeBannerDto

    var bannerImageUrl: String? {
        banner.mobileImage?.previewUrl
            ?? banner.displayImage?.previewUrl
            ?? banner.desktopImage?.previewUrl
    }

    var body: some View {
        Group {
            if let targetUrl = banner.targetUrl, let url = URL(string: targetUrl) {
                Link(destination: url) {
                    bannerImage
                }
            } else {
                bannerImage
            }
        }
    }

    private var bannerImage: some View {
        HeritageListImage(
            imageUrl: bannerImageUrl,
            fallbackText: loc.localized("brand_fallback")
        )
        .frame(width: 300, height: 156)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Article Row

struct ArticleRow: View {
    @Environment(LocalizationManager.self) private var loc
    let article: ArticleSummaryDto
    let prominent: Bool
    let onClick: (() -> Void)?

    var imageUrl: String? {
        article.coverImage?.previewUrl
    }

    var body: some View {
        HeritageListCard(
            onClick: onClick,
            prominent: prominent,
            image: {
                HeritageListImage(
                    imageUrl: imageUrl,
                    fallbackText: loc.localized("brand_fallback")
                )
                .frame(
                    width: prominent ? nil : 104,
                    height: prominent ? 200 : 82
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
            },
            text: {
                HeritageMetaChip(text: article.category.label)
                Text(article.title?.isEmpty == false ? article.title! : loc.localized("unnamed_article"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(prominent ? 3 : 2)
                Text(article.summary?.isEmpty == false ? article.summary! : (article.publishedAt ?? ""))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        )
    }
}
