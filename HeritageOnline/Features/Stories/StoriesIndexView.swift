import SwiftUI

/// 数据故事首页
/// 对齐 Android StoriesIndexScreen
/// 按地区、分类、年份展示故事入口
struct StoriesIndexView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @State private var viewModel = StoriesIndexViewModel()

    @State private var navigateToStory: StoryNavigation?

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.uiState.isLoading && viewModel.uiState.regions.isEmpty {
                    LoadingPlaceholder()
                } else if let error = viewModel.uiState.error {
                    errorView(error)
                } else {
                    StoriesIndexContent(
                        regions: viewModel.uiState.regions,
                        categories: viewModel.uiState.categories,
                        years: viewModel.uiState.years,
                        onRegionStoryClick: { navigateToStory = StoryNavigation(region: $0) },
                        onCategoryStoryClick: { navigateToStory = StoryNavigation(category: $0) },
                        onYearStoryClick: { navigateToStory = StoryNavigation(year: $0) }
                    )
                }
            }
        }
        .navigationTitle("page.stories")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadAll()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.uiState.regions.isEmpty && viewModel.uiState.error == nil {
                viewModel.loadAll()
            }
        }
        .navigationDestination(item: $navigateToStory) { nav in
            StoryDetailView(region: nav.region, category: nav.category, year: nav.year)
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
            Button("action.retry") { viewModel.loadAll() }
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Stories Index Content

private struct StoriesIndexContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let regions: [TaxonomyTopicDTO]
    let categories: [TaxonomyTopicDTO]
    let years: [TimelineYearBucketDTO]
    let onRegionStoryClick: (String) -> Void
    let onCategoryStoryClick: (String) -> Void
    let onYearStoryClick: (Int) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // 按地区阅读
                if !regions.isEmpty {
                    StorySection(
                        title: String(localized: "stories.byRegion"),
                        items: regions.compactMap { topic in
                            guard let key = topic.key else { return nil }
                            return StoryCardItem(
                                title: topic.title ?? key,
                                subtitle: "\(topic.total) " + String(localized: "stats.total"),
                                action: { onRegionStoryClick(key) }
                            )
                        }
                    )
                }

                // 按分类阅读
                if !categories.isEmpty {
                    StorySection(
                        title: String(localized: "stories.byCategory"),
                        items: categories.compactMap { topic in
                            guard let key = topic.key else { return nil }
                            return StoryCardItem(
                                title: topic.title ?? key,
                                subtitle: "\(topic.total) " + String(localized: "stats.total"),
                                action: { onCategoryStoryClick(key) }
                            )
                        }
                    )
                }

                // 按年份阅读
                if !years.isEmpty {
                    StorySection(
                        title: String(localized: "stories.byYear"),
                        items: years.map { year in
                            StoryCardItem(
                                title: "\(year.year)",
                                subtitle: "\(year.total) " + String(localized: "stats.total"),
                                action: { onYearStoryClick(year.year) }
                            )
                        }
                    )
                }

                Spacer().frame(height: 18)
            }
            .padding(.vertical, 18)
        }
    }
}

// MARK: - Story Section

private struct StorySection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let title: String
    let items: [StoryCardItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Button(action: item.action) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(HeritageTypography.titleMedium)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                    .foregroundStyle(colorScheme.onSurface)

                                Text(item.subtitle)
                                    .font(HeritageTypography.bodyMedium)
                                    .foregroundStyle(colorScheme.onSurfaceVariant)
                            }
                            .padding(12)
                            .frame(width: 160, alignment: .leading)
                            .background(colorScheme.surfaceContainerHigh)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct StoryCardItem {
    let title: String
    let subtitle: String
    let action: () -> Void
}

#Preview {
    NavigationStack {
        StoriesIndexView()
    }
    .heritageTheme()
}
