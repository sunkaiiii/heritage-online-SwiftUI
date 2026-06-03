import SwiftUI

/// 我的页
/// 对齐 Android MyPage
struct MyPageView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let onBack: () -> Void
    let onNavigate: (SavedContent) -> Void

    @State private var viewModel = MyPageViewModel()
    @State private var showClearConfirm = false

    var body: some View {
        NavigationStack {
            PageBackground {
                VStack(spacing: 0) {
                    // Tab 切换
                    tabToggle

                    // 内容
                    if viewModel.selectedTab == .favorites {
                        favoritesTab
                    } else {
                        recentlyViewedTab
                    }
                }
            }
            .navigationTitle("page.my")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("nav.back") { onBack() }
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
        }
    }

    // MARK: - Tab 切换

    private var tabToggle: some View {
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
                    // 清空按钮
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

                    // 浏览记录列表
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
}

// MARK: - 保存内容行

private struct SavedContentRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: SavedContent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 图片
                HeritageListImage(
                    urlString: item.imageUrl,
                    placeholderText: item.title,
                    width: 60,
                    height: 60
                )

                // 信息
                VStack(alignment: .leading, spacing: 4) {
                    // 类型标签
                    Text(ContentLabels.localizedContentType(item.contentType.rawValue))
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.primary)

                    // 标题
                    Text(item.title)
                        .font(HeritageTypography.titleMedium)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineLimit(2)

                    // 副标题/摘要
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

// MARK: - SavedContent 导航目标

extension SavedContent {
    /// 判断应该切换到哪个主 tab
    var targetTab: HomeTab {
        switch contentType {
        case .article: return .articles
        case .directoryItem: return .directory
        case .inheritor: return .inheritors
        }
    }
}
