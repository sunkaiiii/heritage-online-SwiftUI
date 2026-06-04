import SwiftUI

/// 探索主题详情页
/// 对齐 Android ExploreTopicScreen
/// 展示主题标题、统计、sections、时间线、相关主题
struct ExploreTopicView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel: ExploreTopicViewModel

    /// 子导航状态
    @State private var navigateToArticle: String?
    @State private var navigateToDirectory: String?
    @State private var navigateToInheritor: String?
    @State private var navigateToRelatedTopic: ExploreTopicLinkDTO?

    init(type: String, key: String) {
        _viewModel = State(initialValue: ExploreTopicViewModel(type: type, key: key))
    }

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.isLoading && viewModel.topic == nil {
                    LoadingPlaceholder()
                } else if let error = viewModel.error, viewModel.topic == nil {
                    errorView(error)
                } else if let topic = viewModel.topic {
                    ExploreTopicContent(
                        topic: topic,
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
        .navigationTitle(viewModel.topic?.topic?.title ?? String(localized: "contentType.topic"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadTopic()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.topic == nil && viewModel.error == nil {
                viewModel.loadTopic()
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
                viewModel.loadTopic()
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - 探索主题内容

/// 探索主题内容（无状态）
private struct ExploreTopicContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let topic: ExploreTopicV2DTO
    let onItemClick: (ExploreTopicItemDTO) -> Void
    let onRelatedTopicClick: (ExploreTopicLinkDTO) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // 主题信息
                if let topicInfo = topic.topic {
                    VStack(alignment: .leading, spacing: 4) {
                        if let typeKey = ContentLabels.exploreTopicTypeKey(topicInfo.type) {
                            MetaChip(LocalizedStringKey(typeKey))
                        }
                        Text(topicInfo.title ?? "")
                            .font(HeritageTypography.headlineMedium)
                            .foregroundStyle(colorScheme.onSurface)

                        if let subtitle = topicInfo.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(HeritageTypography.bodyLarge)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 统计
                if !topic.stats.isEmpty {
                    ExploreTopicStatsRow(stats: topic.stats)
                        .padding(.horizontal, 20)
                }

                // Sections
                ForEach(Array(topic.sections.enumerated()), id: \.offset) { _, section in
                    ExploreTopicSectionView(
                        section: section,
                        onItemClick: onItemClick
                    )
                }

                // 时间线
                if !topic.timeline.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "discovery.timeline"))

                        ForEach(Array(topic.timeline.enumerated()), id: \.offset) { _, item in
                            TopicTimelineRow(item: item) {
                                onItemClick(item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // 相关主题
                if !topic.relatedTopics.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: String(localized: "context.exploreTopics"))

                        FlowLayout(spacing: 8) {
                            ForEach(Array(topic.relatedTopics.enumerated()), id: \.offset) { _, link in
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

// MARK: - 统计行

/// 探索主题统计行
private struct ExploreTopicStatsRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let stats: [ExploreTopicStatDTO]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(stats.enumerated()), id: \.offset) { _, stat in
                VStack(spacing: 4) {
                    Text("\(stat.value)")
                        .font(HeritageTypography.titleLarge)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.primary)

                    Text(stat.name ?? "")
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(colorScheme.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

// MARK: - 主题区块

/// 探索主题区块视图
private struct ExploreTopicSectionView: View {
    let section: ExploreTopicSectionDTO
    let onItemClick: (ExploreTopicItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = section.title, !title.isEmpty {
                SectionHeader(title: title)
                    .padding(.horizontal, 20)
            }

            if !section.items.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                            TopicItemCard(item: item) {
                                onItemClick(item)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - 主题项卡片

/// 探索主题内容项卡片
private struct TopicItemCard: View {
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

                    HStack(spacing: 4) {
                        if let category = item.category, !category.isEmpty {
                            MetaChip(LocalizedStringKey(ContentLabels.articleCategoryKey(category) ?? category))
                        }
                        if let region = item.region, !region.isEmpty {
                            MetaChip(region)
                        }
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

// MARK: - 时间线行

/// 主题时间线行
private struct TopicTimelineRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: ExploreTopicItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                // 左侧年份/类型
                VStack(spacing: 2) {
                    if let year = item.year {
                        Text("\(year)")
                            .font(HeritageTypography.titleMedium)
                            .fontWeight(.bold)
                            .foregroundStyle(colorScheme.primary)
                    }
                    if let type = item.type {
                        Text(LocalizedStringKey(ContentLabels.contentTypeKey(type)))
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
                .frame(width: 60)

                // 分隔线
                Rectangle()
                    .fill(colorScheme.outlineVariant)
                    .frame(width: 1)

                // 右侧内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title ?? "")
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    if let summary = item.summary, !summary.isEmpty {
                        Text(summary)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(2)
                    }

                    HStack(spacing: 4) {
                        if let category = item.category, !category.isEmpty {
                            MetaChip(LocalizedStringKey(ContentLabels.articleCategoryKey(category) ?? category))
                        }
                        if let region = item.region, !region.isEmpty {
                            MetaChip(region)
                        }
                    }
                }

                Spacer()
            }
            .padding(12)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Identifiable / Hashable Extensions

extension ExploreTopicLinkDTO: Identifiable {
    public var id: String { (type ?? "") + ":" + (key ?? "") }
}

extension ExploreTopicLinkDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(key)
    }

    public static func == (lhs: ExploreTopicLinkDTO, rhs: ExploreTopicLinkDTO) -> Bool {
        lhs.type == rhs.type && lhs.key == rhs.key
    }
}

#Preview {
    NavigationStack {
        ExploreTopicView(type: "category", key: "传统音乐")
    }
    .heritageTheme()
}
