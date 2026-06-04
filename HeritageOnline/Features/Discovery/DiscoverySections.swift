import SwiftUI

struct TodaySection: View {
    let today: DiscoveryTodayDTO
    let onItemClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.today"))

            if let featuredDirectoryItem = today.featuredDirectoryItem {
                DiscoveryItemRow(
                    item: featuredDirectoryItem,
                    onClick: { onItemClick(featuredDirectoryItem) }
                )
                .padding(.horizontal, 16)
            }

            if let featuredInheritor = today.featuredInheritor {
                DiscoveryItemRow(
                    item: featuredInheritor,
                    onClick: { onItemClick(featuredInheritor) }
                )
                .padding(.horizontal, 16)
            }

            if !today.articles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(today.articles, id: \.id) { article in
                            DiscoveryItemCard(
                                item: article,
                                onClick: { onItemClick(article) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

struct TrendingSection: View {
    let trending: DiscoveryTrendingDTO
    let onItemClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.trending"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(trending.items, id: \.id) { item in
                        DiscoveryItemCard(
                            item: item,
                            onClick: { onItemClick(item) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct WeeklySection: View {
    let weekly: DiscoveryWeeklyDTO
    let onItemClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.weekly"))

            ForEach(weekly.sections.prefix(2), id: \.id) { section in
                VStack(alignment: .leading, spacing: 6) {
                    Text(section.title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)

                    if let subtitle = section.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(section.items.prefix(5), id: \.id) { item in
                                DiscoveryItemCard(
                                    item: item,
                                    onClick: { onItemClick(item) }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

struct ClassicSections: View {
    let classic: DiscoveryClassicData
    let onTopicClick: (ExploreTopicInfoDTO) -> Void
    let onLearningPathClick: (LearningPathDTO) -> Void
    let onCollectionClick: (FeaturedCollectionDTO) -> Void
    let onRegionAtlasClick: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // 探索主题
            if !classic.topics.isEmpty {
                ExploreTopicsSection(
                    topics: classic.topics,
                    onTopicClick: onTopicClick
                )
            }

            // 学习路径
            if !classic.learningPaths.isEmpty {
                LearningPathsSection(
                    paths: classic.learningPaths,
                    onPathClick: onLearningPathClick
                )
            }

            // 精选合集
            if !classic.featuredCollections.isEmpty {
                FeaturedCollectionsSection(
                    collections: classic.featuredCollections,
                    onCollectionClick: onCollectionClick
                )
            }

            // 地区图谱
            if let atlas = classic.regionAtlas {
                RegionAtlasCard(
                    atlas: atlas,
                    onClick: onRegionAtlasClick
                )
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ExploreTopicsSection: View {
    let topics: [ExploreTopicInfoDTO]
    let onTopicClick: (ExploreTopicInfoDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.topics"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(topics, id: \.key) { topic in
                        Button(action: { onTopicClick(topic) }) {
                            Text(topic.title ?? topic.key ?? "")
                                .font(HeritageTypography.labelLarge)
                                .lineLimit(1)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct LearningPathsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let paths: [LearningPathDTO]
    let onPathClick: (LearningPathDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.learningPaths"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(paths.enumerated()), id: \.offset) { _, path in
                        LearningPathCard(
                            path: path,
                            onClick: { onPathClick(path) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct FeaturedCollectionsSection: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collections: [FeaturedCollectionDTO]
    let onCollectionClick: (FeaturedCollectionDTO) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: String(localized: "discovery.collections"))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(collections.enumerated()), id: \.offset) { _, collection in
                        FeaturedCollectionCard(
                            collection: collection,
                            onClick: { onCollectionClick(collection) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct RegionAtlasCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let atlas: RegionAtlasDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "discovery.regionAtlas"))
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onPrimaryContainer)

                    Text(String(format: String(localized: "discovery.regionCount %lld"), atlas.totals?.regionCount ?? 0))
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onPrimaryContainer)
                }

                Spacer()

                Text(String(localized: "action.viewDetail"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(16)
            .background(colorScheme.primaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct TimelineCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "discovery.timeline"))
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onSecondaryContainer)

                    Text(String(localized: "discovery.timeline.subtitle"))
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSecondaryContainer)
                }

                Spacer()

                Text(String(localized: "action.viewDetail"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(16)
            .background(colorScheme.secondaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

