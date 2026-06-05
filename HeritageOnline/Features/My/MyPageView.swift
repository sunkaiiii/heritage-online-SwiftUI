import SwiftUI

/// 我的页
/// 对齐 Android MyPage
struct MyPageView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let onBack: () -> Void
    let onNavigate: (SavedContent) -> Void
    let onNavigateReadingPath: (ReadingPathEvent) -> Void

    @State private var viewModel = MyPageViewModel()
    @State private var showClearConfirm = false
    @State private var showClearReadingPathConfirm = false

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack(spacing: 0) {
                    // Tab 切换
                    tabToggle

                    // 内容
                    switch viewModel.selectedTab {
                    case .favorites:
                        favoritesTab
                    case .recentlyViewed:
                        recentlyViewedTab
                    case .readingPath:
                        readingPathTab
                    }
                }
                #if os(macOS)
                .frame(maxWidth: 920)
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                #endif
            }
            .navigationTitle("page.my")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("nav.back") { onBack() }
                }
            }
            #elseif os(macOS)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onBack()
                    } label: {
                        Label("nav.close", systemImage: "xmark")
                    }
                }
            }
            #endif
            .task { await viewModel.load() }
            .alert("my.clearRecent.confirm", isPresented: $showClearConfirm) {
                Button("nav.cancel", role: .cancel) {}
                Button("action.clear", role: .destructive) {
                    Task { await viewModel.clearRecent() }
                }
            }
            .alert("my.clearReadingPath.confirm", isPresented: $showClearReadingPathConfirm) {
                Button("nav.cancel", role: .cancel) {}
                Button("action.clear", role: .destructive) {
                    Task { await viewModel.clearReadingPath() }
                }
            }
        }
    }

    // MARK: - Tab 切换

    private var tabToggle: some View {
        #if os(macOS)
        Picker("page.my", selection: Binding(
            get: { viewModel.selectedTab },
            set: { viewModel.selectedTab = $0 }
        )) {
            ForEach(MyPageTab.allCases, id: \.self) { tab in
                Text(tab.localizationKey).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 560)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        #else
        HStack(spacing: 0) {
            ForEach(MyPageTab.allCases, id: \.self) { tab in
                Button {
                    viewModel.selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.localizationKey)
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(
                                viewModel.selectedTab == tab
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant
                            )
                        Rectangle()
                            .fill(viewModel.selectedTab == tab ? colorScheme.primary : Color.clear)
                            .frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
        #endif
    }

    // MARK: - 收藏 Tab

    private var favoritesTab: some View {
        Group {
            if viewModel.favorites.isEmpty {
                EmptyState(
                    icon: "heart",
                    title: "my.empty.favorites",
                    message: "my.empty.favorites.hint"
                )
            } else {
                List {
                    ForEach(viewModel.favorites) { item in
                        SavedContentRow(item: item) {
                            onNavigate(item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.unfavorite(item) }
                            } label: {
                                Label("action.unfavorite", systemImage: "heart.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - 最近浏览 Tab

    private var recentlyViewedTab: some View {
        Group {
            if viewModel.recentlyViewed.isEmpty {
                EmptyState(
                    icon: "clock",
                    title: "my.empty.recentlyViewed",
                    message: "my.empty.recentlyViewed.hint"
                )
            } else {
                List {
                    Section {
                        Button {
                            showClearConfirm = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("my.clearRecent", systemImage: "trash")
                                    .font(HeritageTypography.labelLarge)
                                    .foregroundStyle(colorScheme.error)
                                Spacer()
                            }
                        }
                    }

                    ForEach(viewModel.recentlyViewed) { item in
                        SavedContentRow(item: item) {
                            onNavigate(item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeRecent(item) }
                            } label: {
                                Label("my.removeRecent", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - 阅读路径 Tab

    private var readingPathTab: some View {
        Group {
            if viewModel.readingPaths.isEmpty {
                EmptyState(
                    icon: "arrow.triangle.branch",
                    title: "my.empty.readingPath",
                    message: "my.empty.readingPath.hint"
                )
            } else {
                List {
                    Section {
                        Button {
                            showClearReadingPathConfirm = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("my.clearReadingPath", systemImage: "trash")
                                    .font(HeritageTypography.labelLarge)
                                    .foregroundStyle(colorScheme.error)
                                Spacer()
                            }
                        }
                    }

                    ForEach(viewModel.readingPaths) { event in
                        ReadingPathRow(event: event) {
                            onNavigateReadingPath(event)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - 保存内容行

private struct SavedContentRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: SavedContent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                HeritageListImage(
                    urlString: item.imageUrl,
                    placeholderText: item.title,
                    width: 60,
                    height: 60
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(ContentLabels.localizedContentType(item.contentType.rawValue))
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.primary)

                    Text(item.title)
                        .font(HeritageTypography.titleMedium)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    if let subtitle = item.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 阅读路径行

private struct ReadingPathRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let event: ReadingPathEvent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // From -> To
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ContentLabels.localizedContentType(event.fromType.rawValue))
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                        Text(event.fromTitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(1)
                    }

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12))
                        .foregroundStyle(colorScheme.onSurfaceVariant)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(ContentLabels.localizedContentType(event.toType.rawValue))
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.primary)
                        Text(event.toTitle)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(1)
                    }
                }

                // Source tag
                HStack {
                    MetaChip(event.source.displayName)
                        .font(HeritageTypography.labelMedium)
                    Spacer()
                    Text(event.createdAt, style: .relative)
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SavedContent 导航目标

extension SavedContent {
    var targetTab: HomeTab {
        switch contentType {
        case .article: return .articles
        case .directoryItem: return .directory
        case .inheritor: return .inheritors
        }
    }
}

// MARK: - ReadingPathEvent 导航目标

extension ReadingPathEvent {
    /// 目标 tab
    var targetTab: HomeTab {
        switch toType {
        case .article: return .articles
        case .directoryItem: return .directory
        case .inheritor: return .inheritors
        }
    }
}
