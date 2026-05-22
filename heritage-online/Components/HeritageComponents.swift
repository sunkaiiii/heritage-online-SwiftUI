import SwiftUI

// MARK: - Page Background

struct HeritagePageBackground<Content: View>: View {
    @Environment(ThemeManager.self) private var theme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
    }
}

// MARK: - Page Header

struct HeritagePageHeader: View {
    @Environment(ThemeManager.self) private var theme
    let title: String
    let subtitle: String?

    init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(theme.onBackground)
            if let subtitle = subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }
}

// MARK: - Section Header

struct HeritageSectionHeader: View {
    @Environment(ThemeManager.self) private var theme
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Divider()
                .overlay(theme.outlineVariant)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Content Card

struct HeritageContentCard<Content: View>: View {
    @Environment(ThemeManager.self) private var theme
    let onClick: (() -> Void)?
    @ViewBuilder let content: () -> Content

    init(onClick: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.onClick = onClick
        self.content = content
    }

    var body: some View {
        Group {
            if let onClick = onClick {
                Button(action: onClick) { cardContent }
                    .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        content()
            .frame(maxWidth: .infinity)
            .background(theme.surfaceContainer)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Meta Chip

struct HeritageMetaChip: View {
    @Environment(ThemeManager.self) private var theme
    let text: String
    var isSelected: Bool = false

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(isSelected ? theme.onPrimaryContainer : theme.onSurfaceVariant)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? theme.primaryContainer : theme.surfaceContainerHigh)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.outlineVariant, lineWidth: isSelected ? 0 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - List Image

struct HeritageListImage: View {
    @Environment(ThemeManager.self) private var theme
    let imageUrl: String?
    let fallbackText: String

    var body: some View {
        HeritageAsyncImage(
            url: imageUrl.flatMap(URL.init(string:))
        ) { image in
            image.resizable()
        } placeholder: {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        ZStack {
            theme.surfaceContainerHigh
            Text(fallbackText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.onSurfaceVariant.opacity(0.82))
        }
    }
}

// MARK: - List Card

struct HeritageListCard<ImageView: View, TextView: View>: View {
    let onClick: (() -> Void)?
    let prominent: Bool
    @ViewBuilder let image: () -> ImageView
    @ViewBuilder let text: () -> TextView

    init(
        onClick: (() -> Void)? = nil,
        prominent: Bool = false,
        @ViewBuilder image: @escaping () -> ImageView,
        @ViewBuilder text: @escaping () -> TextView
    ) {
        self.onClick = onClick
        self.prominent = prominent
        self.image = image
        self.text = text
    }

    var body: some View {
        HeritageContentCard(onClick: onClick) {
            if prominent {
                VStack(alignment: .leading, spacing: 10) {
                    image()
                    text()
                }
                .padding(14)
            } else {
                HStack(alignment: .top, spacing: 14) {
                    image()
                    VStack(alignment: .leading, spacing: 6) {
                        text()
                    }
                }
                .padding(14)
            }
        }
    }
}

// MARK: - Fact

struct HeritageFact: Identifiable {
    let id = UUID()
    let label: String
    let value: String
}

// MARK: - Fact Card

struct HeritageFactCard: View {
    @Environment(ThemeManager.self) private var theme
    let facts: [HeritageFact]

    var body: some View {
        if facts.isEmpty { EmptyView() }
        HeritageContentCard {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(facts) { fact in
                    HStack(alignment: .top, spacing: 12) {
                        Text(fact.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.primary)
                            .frame(minWidth: 100, alignment: .leading)
                        Text(fact.value)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Reference Card

struct HeritageReferenceCard: View {
    let title: String
    let meta: String?
    let onClick: (() -> Void)?

    var body: some View {
        HeritageContentCard(onClick: onClick) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                if let meta = meta, !meta.isEmpty {
                    Text(meta)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(14)
        }
    }
}

// MARK: - Detail Image

struct HeritageDetailImage: View {
    @Environment(ThemeManager.self) private var theme
    let imageUrl: String?
    let fallbackText: String

    var body: some View {
        HeritageAsyncImage(
            url: imageUrl.flatMap(URL.init(string:))
        ) { image in
            image.resizable()
        } placeholder: {
            imagePlaceholder
        }
        .background(theme.surfaceContainerHigh)
    }

    private var imagePlaceholder: some View {
        ZStack {
            theme.surfaceContainerHigh
            Text(fallbackText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(theme.onSurfaceVariant.opacity(0.82))
        }
    }
}

// MARK: - Filter Button

struct HeritageFilterButton: View {
    @Environment(ThemeManager.self) private var theme
    let activeFilterCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.body)
                if activeFilterCount > 0 {
                    Text("\(activeFilterCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(theme.onPrimary)
                        .frame(width: 16, height: 16)
                        .background(theme.primary)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
        }
    }
}

// MARK: - Loading Content

struct LoadingContent: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(String(localized: "content_loading"))
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

// MARK: - Error Content

struct ErrorContent: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(String(localized: "content_load_failed"))
                .font(.headline)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
            Button(action: onRetry) {
                Text(String(localized: "action_retry"))
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(28)
    }
}

// MARK: - Empty Content

struct EmptyContent: View {
    let message: String
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(String(localized: "content_empty_title"))
                .font(.headline)
                .fontWeight(.semibold)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
            Button(action: onRefresh) {
                Text(String(localized: "action_refresh"))
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(28)
    }
}

// MARK: - Inline Retry Message

struct InlineRetryMessage: View {
    @Environment(ThemeManager.self) private var theme
    let message: String
    let onRetry: () -> Void

    var body: some View {
        HStack {
            Text(message)
                .font(.body)
                .foregroundColor(theme.onPrimaryContainer)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(String(localized: "action_retry")) {
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(theme.onPrimaryContainer)
        }
        .padding(14)
        .background(theme.primary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 20)
    }
}

// MARK: - Stale Content Warning

struct StaleContentWarning: View {
    @Environment(ThemeManager.self) private var theme
    let onRetry: () -> Void

    var body: some View {
        HStack {
            Text(String(localized: "content_may_be_stale"))
                .font(.body)
                .foregroundColor(theme.onPrimaryContainer)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(String(localized: "action_retry")) {
                onRetry()
            }
            .buttonStyle(.bordered)
            .tint(theme.onPrimaryContainer)
        }
        .padding(14)
        .background(theme.primary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
