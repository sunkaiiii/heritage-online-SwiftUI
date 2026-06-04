import SwiftUI

/// 故事详情页
/// 对齐 Android StoryScreen
/// 展示故事标题、区块、内容项、相关主题
struct StoryDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel: StoryDetailViewModel

    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?
    @State private var navigateToTopic: TopicNavigation?

    init(region: String? = nil, category: String? = nil, year: Int? = nil) {
        _viewModel = State(initialValue: StoryDetailViewModel(region: region, category: category, year: year))
    }

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.uiState.isLoading {
                    LoadingPlaceholder()
                } else if let error = viewModel.uiState.error {
                    errorView(error)
                } else if let story = viewModel.uiState.story {
                    StoryContent(
                        story: story,
                        onItemClick: { item in
                            handleItemClick(item)
                        },
                        onTopicClick: { type, key in
                            navigateToTopic = TopicNavigation(type: type, key: key)
                        }
                    )
                }
            }
        }
        .navigationTitle(viewModel.uiState.story?.title ?? String(localized: "page.stories"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        #endif
        .task {
            if viewModel.uiState.story == nil && viewModel.uiState.error == nil {
                viewModel.loadStory()
            }
        }
        .navigationDestination(item: $navigateToArticle) { id in
            ArticleDetailView(articleId: id)
        }
        .navigationDestination(item: $navigateToDirectory) { id in
            DirectoryDetailView(itemId: id)
        }
        .navigationDestination(item: $navigateToInheritor) { id in
            InheritorDetailView(inheritorId: id)
        }
        .navigationDestination(item: $navigateToTopic) { nav in
            ExploreTopicView(type: nav.type, key: nav.key)
        }
    }

    private func handleItemClick(_ item: DataStoryItemDTO) {
        guard let id = item.id, !id.isEmpty else { return }
        switch item.type {
        case "article": navigateToArticle = id
        case "directoryItem": navigateToDirectory = id
        case "inheritor": navigateToInheritor = id
        default: break
        }
    }

    private func errorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)
            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)
            Button("action.retry") { viewModel.loadStory() }
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Story Content

private struct StoryContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let story: DataStoryDTO
    let onItemClick: (DataStoryItemDTO) -> Void
    let onTopicClick: (String, String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // Hero Image
                if let heroImage = story.heroImage {
                    let urlString = ImagePreviewUrl.previewUrl(from: heroImage)
                    HeritageDetailImage(
                        urlString: urlString,
                        placeholderText: story.title ?? "E",
                        contentMode: .fit,
                        onTap: {}
                    )
                    .aspectRatio(16/9, contentMode: .fit)
                }

                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.title ?? "")
                        .font(HeritageTypography.headlineMedium)
                        .foregroundStyle(colorScheme.onSurface)

                    if let subtitle = story.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyLarge)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }

                // Sections
                ForEach(Array(story.sections.enumerated()), id: \.offset) { _, section in
                    StorySectionView(
                        section: section,
                        onItemClick: onItemClick
                    )
                }

                // Related Topics
                if !story.relatedTopics.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "context.exploreTopics"))
                        FlowLayout(spacing: 8) {
                            ForEach(Array(story.relatedTopics.enumerated()), id: \.offset) { _, topic in
                                Button(action: {
                                    if let type = topic.type, let key = topic.key {
                                        onTopicClick(type, key)
                                    }
                                }) {
                                    MetaChip(topic.title ?? topic.key ?? "")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Spacer().frame(height: 18)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
    }
}

// MARK: - Story Section View

private struct StorySectionView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let section: DataStorySectionDTO
    let onItemClick: (DataStoryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = section.title, !title.isEmpty {
                SectionHeader(title: title)
            }

            if let body = section.body, !body.isEmpty {
                Text(body)
                    .font(HeritageTypography.bodyLarge)
                    .foregroundStyle(colorScheme.onSurface)
                    .lineSpacing(6)
            }

            if !section.items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                            StoryItemCard(item: item) {
                                onItemClick(item)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Story Item Card

private struct StoryItemCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DataStoryItemDTO
    let onClick: () -> Void

    private var bestImageUrl: String? {
        item.coverImage?.displayUrl ?? item.coverImage?.thumbnailUrl ?? item.coverImage?.originalUrl
    }

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
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

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    if let type = item.type {
                        Text(LocalizedStringKey(ContentLabels.contentTypeKey(type)))
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.primary)
                    }

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
        StoryDetailView(region: "北京")
    }
    .heritageTheme()
}
