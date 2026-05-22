import SwiftUI

struct ArticleDetailScreen: View {
    let articleId: String?
    let sourceId: String?
    let sourceUrl: String?
    let category: ArticleCategory

    @State private var viewModel: ArticleDetailViewModel
    @State private var showImagePreview = false
    @State private var previewIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(
        articleId: String? = nil,
        sourceId: String? = nil,
        sourceUrl: String? = nil,
        category: ArticleCategory = .news
    ) {
        self.articleId = articleId
        self.sourceId = sourceId
        self.sourceUrl = sourceUrl
        self.category = category
        self._viewModel = State(initialValue: ArticleDetailViewModel(
            articleId: articleId,
            sourceId: sourceId,
            sourceUrl: sourceUrl,
            category: category
        ))
    }

    private var detailToolbarButtons: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? Color(hex: "8F372F") : .secondary)
            }
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }

    var previewUrls: [String] {
        guard let article = viewModel.article else { return [] }
        var urls: [String] = []
        if let coverUrl = article.coverImage?.previewUrl { urls.append(coverUrl) }
        for block in article.contentBlocks {
            if block.type == .image, let url = block.image?.previewUrl {
                urls.append(url)
            }
        }
        return urls
    }

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    if viewModel.isLoading {
                        LoadingContent()
                    } else if let error = viewModel.errorMessage {
                        ErrorContent(message: error) {
                            Task { await viewModel.refresh() }
                        }
                    } else if let article = viewModel.article {
                        if viewModel.isContentStale {
                            StaleContentWarning {
                                Task { await viewModel.refresh() }
                            }
                        }

                        heroSection(article: article)
                        factsSection(article: article)
                        descriptionSection(article: article)
                        contentBlocksSection(article: article)
                        relatedArticlesSection(article: article)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(Color(hex: "FCF8F5"))
        }
        .navigationTitle(String(localized: "article_detail_title"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                detailToolbarButtons
            }
            #else
            ToolbarItem(placement: .automatic) {
                detailToolbarButtons
            }
            #endif
        }
        .task {
            await viewModel.load()
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showImagePreview) {
            ImagePreviewView(
                imageUrls: previewUrls,
                initialIndex: previewIndex
            ) {
                showImagePreview = false
            }
        }
        #else
        .sheet(isPresented: $showImagePreview) {
            ImagePreviewView(
                imageUrls: previewUrls,
                initialIndex: previewIndex
            ) {
                showImagePreview = false
            }
        }
        #endif
    }

    @ViewBuilder
    private func heroSection(article: ArticleDetailDto) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HeritageMetaChip(text: article.category.label)

            if let coverUrl = article.coverImage?.previewUrl {
                HeritageDetailImage(
                    imageUrl: coverUrl,
                    fallbackText: String(localized: "brand_fallback")
                )
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onTapGesture {
                    previewIndex = 0
                    showImagePreview = true
                }
            }

            Text(article.title?.isEmpty == false ? article.title! : String(localized: "unnamed_article"))
                .font(.title)
                .fontWeight(.bold)

            if let sourceName = article.sourceName, !sourceName.isEmpty {
                HStack(spacing: 4) {
                    Text(String(localized: "article_source") + ": ")
                        .font(.caption)
                    Text(sourceName)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.secondary)
            }

            if let publishedAt = article.publishedAt, !publishedAt.isEmpty {
                Text(publishedAt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let sourceUrl = article.sourceUrl, !sourceUrl.isEmpty, let url = URL(string: sourceUrl) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text(String(localized: "article_open_source"))
                    }
                    .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private func factsSection(article: ArticleDetailDto) -> some View {
        let facts = [
            article.author?.isEmpty == false ? HeritageFact(label: String(localized: "article_author"), value: article.author!) : nil,
            article.editor?.isEmpty == false ? HeritageFact(label: String(localized: "article_editor"), value: article.editor!) : nil,
        ].compactMap { $0 }

        if !facts.isEmpty {
            HeritageFactCard(facts: facts)
        }
    }

    @ViewBuilder
    private func descriptionSection(article: ArticleDetailDto) -> some View {
        if let summary = article.summary, !summary.isEmpty {
            Text(summary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
        }
    }

    @ViewBuilder
    private func contentBlocksSection(article: ArticleDetailDto) -> some View {
        let offset = article.coverImage?.previewUrl != nil ? 1 : 0
        ForEach(Array(article.contentBlocks.enumerated()), id: \.offset) { idx, block in
            Group {
                switch block.type {
                case .heading:
                    if let text = block.text, !text.isEmpty {
                        Text(text)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top, 4)
                    }
                case .text:
                    if let text = block.text, !text.isEmpty {
                        Text(text)
                            .font(.body)
                            .lineSpacing(4)
                    }
                case .image:
                    if let image = block.image, let imageUrl = image.previewUrl {
                        let previewIdx = offset + article.contentBlocks.prefix(idx).filter { $0.type == .image }.count
                        HeritageDetailImage(
                            imageUrl: imageUrl,
                            fallbackText: String(localized: "brand_fallback")
                        )
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .onTapGesture {
                            previewIndex = previewIdx
                            showImagePreview = true
                        }
                        .onAppear { }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func relatedArticlesSection(article: ArticleDetailDto) -> some View {
        if !article.relatedArticles.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: String(localized: "article_related_articles_title"))
                ForEach(Array(article.relatedArticles.enumerated()), id: \.offset) { _, reference in
                    if let title = reference.title {
                        HeritageReferenceCard(
                            title: title,
                            meta: reference.publishedAt,
                            onClick: nil
                        )
                    }
                }
            }
        }
    }
}
