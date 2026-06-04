import SwiftUI

struct DiscoveryHeader: View {
    let onRefresh: () -> Void

    var body: some View {
        PageHeader(
            titleKey: "page.discovery",
            subtitleKey: "page.discovery.subtitle",
            actions: [
                .init(
                    icon: "arrow.clockwise",
                    accessibilityLabelKey: "action.refresh",
                    action: onRefresh
                )
            ]
        )
    }
}

struct DiscoverySearchBar: View {
    let onSearchSubmit: (String) -> Void
    @State private var searchText = ""

    var body: some View {
        SearchField(
            text: $searchText,
            placeholder: "discovery.searchPlaceholder",
            onSubmit: {
                if !searchText.isEmpty {
                    onSearchSubmit(searchText)
                }
            }
        )
        .padding(.horizontal, 16)
    }
}

struct SerendipityButton: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let isLoading: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Text(isLoading ? String(localized: "loading.exploring") : String(localized: "discovery.serendipity"))
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.onSecondaryContainer)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(colorScheme.secondaryContainer)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .disabled(isLoading)
        .padding(.horizontal, 16)
    }
}

struct SerendipityResultCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let item: DiscoveryItemDTO
    let onItemClick: (DiscoveryItemDTO) -> Void
    let onDeepDiveClick: (DiscoveryItemDTO) -> Void

    var body: some View {
        Button(action: { onItemClick(item) }) {
            VStack(alignment: .leading, spacing: 6) {
                Text(String(localized: "discovery.serendipity"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)

                Text(item.title)
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.bold)
                    .foregroundStyle(colorScheme.onSurface)

                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(3)
                }

                HStack(spacing: 8) {
                    if let category = item.category, !category.isEmpty {
                        MetaChip(category)
                    }
                    if let region = item.region, !region.isEmpty {
                        MetaChip(region)
                    }
                }

                Button(action: { onDeepDiveClick(item) }) {
                    Text(String(localized: "discovery.deepDive"))
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.primary)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct LearningPathCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let path: LearningPathDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(path.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                if let subtitle = path.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                }

                Text(String(format: String(localized: "discovery.stepCount %lld"), path.stepCount))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(12)
            .frame(width: 200, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct FeaturedCollectionCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let collection: FeaturedCollectionDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(collection.title ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .foregroundStyle(colorScheme.onSurface)

                if let subtitle = collection.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .lineLimit(2)
                }

                Text(String(format: String(localized: "discovery.itemCount %lld"), collection.itemCount))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(12)
            .frame(width: 180, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct DiscoveryEntryCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let title: String
    let subtitle: String
    let containerColor: Color
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme.onSurface)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text(String(localized: "action.viewDetail"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
            .padding(16)
            .background(containerColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct SectionContainer<T>: View {
    let section: DiscoverySectionState<T>
    let onRetry: () -> Void
    let loadingContent: () -> AnyView
    let errorContent: (AppError) -> AnyView
    let content: (T) -> AnyView

    init(
        section: DiscoverySectionState<T>,
        onRetry: @escaping () -> Void,
        @ViewBuilder loadingContent: @escaping () -> some View,
        @ViewBuilder errorContent: @escaping (AppError) -> some View,
        @ViewBuilder content: @escaping (T) -> some View
    ) {
        self.section = section
        self.onRetry = onRetry
        self.loadingContent = { AnyView(loadingContent()) }
        self.errorContent = { error in AnyView(errorContent(error)) }
        self.content = { data in AnyView(content(data)) }
    }

    var body: some View {
        VStack {
            if section.isLoading && !section.hasData {
                loadingContent()
            } else if let error = section.error, section.hasError {
                errorContent(error)
            } else if let data = section.data {
                content(data)
            }
        }
    }
}

struct SectionLoadingPlaceholder: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    var body: some View {
        Text(String(localized: "loading.default"))
            .font(HeritageTypography.bodyMedium)
            .foregroundStyle(colorScheme.onSurfaceVariant)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(colorScheme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
    }
}

struct SectionErrorRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        HStack {
            Text(error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Spacer()

            Button(action: onRetry) {
                Text(String(localized: "action.retry"))
                    .font(HeritageTypography.labelMedium)
                    .foregroundStyle(colorScheme.primary)
            }
        }
        .padding(14)
        .background(colorScheme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}

struct DiscoveryErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(error.localizedDescription)
                .font(HeritageTypography.bodyLarge)
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Button(action: onRetry) {
                Text(String(localized: "action.retry"))
                    .font(HeritageTypography.labelLarge)
            }
            .buttonStyle(.bordered)
        }
        .padding(32)
    }
}

extension ExploreTopicInfoDTO: Identifiable, Hashable {
    public var id: String { key ?? UUID().uuidString }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ExploreTopicInfoDTO, rhs: ExploreTopicInfoDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension LearningPathDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: LearningPathDTO, rhs: LearningPathDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension FeaturedCollectionDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: FeaturedCollectionDTO, rhs: FeaturedCollectionDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension DiscoveryItemDTO: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: DiscoveryItemDTO, rhs: DiscoveryItemDTO) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    NavigationStack {
        DiscoveryView()
    }
    .heritageTheme()
}

