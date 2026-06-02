import SwiftUI

/// 名录列表和统计页
/// 对齐 Android DirectoryScreen
/// Step 12 范围：名录列表 + kind chips + 搜索 + 筛选 + 统计 tab
struct DirectoryView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel = DirectoryViewModel()
    @State private var showFilterSheet = false

    var body: some View {
        PageBackground {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header
                    directoryHeader

                    // Tab 切换
                    tabToggle

                    // Kind chips
                    kindFilters

                    // 内容区
                    if viewModel.uiState.selectedTab == .list {
                        listContent
                    } else {
                        statisticsContent
                    }
                }
                .padding(.bottom, 18)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            DirectoryFilterSheet(
                region: viewModel.uiState.regionFilter,
                category: viewModel.uiState.categoryFilter,
                year: viewModel.uiState.yearFilter,
                listType: viewModel.uiState.listTypeFilter,
                onApply: { r, c, y, lt in
                    viewModel.applyFilters(region: r, category: c, year: y, listType: lt)
                    showFilterSheet = false
                },
                onClear: {
                    viewModel.clearAdvancedFilters()
                    showFilterSheet = false
                },
                onDismiss: { showFilterSheet = false }
            )
            .presentationDetents([.medium])
        }
        .task {
            await viewModel.loadItems()
        }
    }

    // MARK: - Header

    private var directoryHeader: some View {
        PageHeader(
            titleKey: "page.directory",
            subtitleKey: "page.directory.subtitle",
            actions: [
                .init(icon: "line.3.horizontal.decrease.circle", accessibilityLabelKey: "nav.filter") {
                    showFilterSheet = true
                },
                .init(icon: "arrow.clockwise", accessibilityLabelKey: "action.refresh") {
                    Task { await viewModel.refresh() }
                }
            ]
        )
    }

    // MARK: - Tab 切换

    private var tabToggle: some View {
        HStack(spacing: 0) {
            ForEach(DirectoryTab.allCases, id: \.self) { tab in
                Button {
                    viewModel.selectTab(tab)
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.localizationKey)
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(
                                viewModel.uiState.selectedTab == tab
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant
                            )
                        Rectangle()
                            .fill(viewModel.uiState.selectedTab == tab
                                ? colorScheme.primary
                                : Color.clear)
                            .frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Kind chips

    private var kindFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(DirectoryItemKind.allCases, id: \.self) { kind in
                    Button {
                        viewModel.selectKind(kind)
                    } label: {
                        MetaChip(kind.displayName, isSelected: viewModel.uiState.selectedKind == kind)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
    }

    // MARK: - 名录列表内容

    @ViewBuilder
    private var listContent: some View {
        // 搜索框（仅名录 tab 显示）
        SearchField(
            text: Binding(
                get: { viewModel.uiState.searchKeywords },
                set: { viewModel.updateSearchKeywords($0) }
            ),
            placeholder: "directory.searchPlaceholder"
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)

        // 活跃筛选 chips（仅名录 tab 显示）
        if viewModel.uiState.activeFilterCount > 0 {
            activeFilterChips
        }

        // 列表内容
        if viewModel.uiState.isLoading {
            ListLoadingPlaceholder(count: 5)
                .padding(.horizontal, 20)
        } else if let error = viewModel.uiState.error {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                Text(LocalizedStringKey(error.localizedDescription))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                Button("action.retry") {
                    Task { await viewModel.loadItems() }
                }
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
        } else if viewModel.uiState.items.isEmpty {
            let isSearching = !viewModel.uiState.searchKeywords.trimmingCharacters(in: .whitespaces).isEmpty
                || viewModel.uiState.activeFilterCount > 0
            EmptyState(
                icon: isSearching ? "doc.text.magnifyingglass" : "tray",
                title: isSearching ? "directory.empty.search" : "directory.empty.default",
                message: isSearching ? "directory.empty.searchHint" : nil
            )
            .frame(minHeight: 300)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.uiState.items.enumerated()), id: \.element.id) { index, item in
                    DirectoryItemRow(item: item)
                        .onAppear {
                            if index >= viewModel.uiState.items.count - 5 {
                                Task { await viewModel.loadMore() }
                            }
                        }
                }
                if viewModel.uiState.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView().tint(colorScheme.primary)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                if let appendError = viewModel.uiState.appendError {
                    ErrorRetryRow(message: LocalizedStringKey(appendError.localizedDescription)) {
                        Task { await viewModel.loadMore() }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - 活跃筛选 chips

    private var activeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                filterChip(field: .region, value: viewModel.uiState.regionFilter)
                filterChip(field: .category, value: viewModel.uiState.categoryFilter)
                filterChip(field: .year, value: viewModel.uiState.yearFilter)
                filterChip(field: .listType, value: viewModel.uiState.listTypeFilter)
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }

    private func filterChip(field: DirectoryFilterField, value: String) -> some View {
        Group {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                Button {
                    viewModel.clearFilterField(field)
                } label: {
                    HStack(spacing: 4) {
                        Text("\(field.localizationKey): \(trimmed)")
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.onPrimaryContainer)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(colorScheme.onPrimaryContainer)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(colorScheme.primaryContainer)
                    .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 统计内容

    @ViewBuilder
    private var statisticsContent: some View {
        DirectoryStatisticsContentView(
            state: viewModel.uiState.statisticsState,
            selectedKind: viewModel.uiState.selectedKind,
            onRetry: { Task { await viewModel.loadStatistics() } }
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - 名录卡片行

private struct DirectoryItemRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DirectoryItemSummaryDTO

    var body: some View {
        NavigationLink(destination: PlaceholderDetailView(titleKey: "page.directory.detail")) {
            ContentCard {
                HStack(spacing: 12) {
                    HeritageListImage(
                        asset: item.coverImage,
                        placeholderText: item.title ?? "E",
                        width: 92,
                        height: 92
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        if let title = item.title, !title.isEmpty {
                            Text(title)
                                .font(HeritageTypography.titleMedium)
                                .foregroundStyle(colorScheme.onSurface)
                                .lineLimit(2)
                        }

                        // Meta chips: category, region, projectCode, publishedYear
                        FlowLayout(spacing: 4) {
                            if let category = item.category, !category.isEmpty {
                                MetaChip(category)
                                    .font(HeritageTypography.labelMedium)
                            }
                            if let region = item.region, !region.isEmpty {
                                MetaChip(region)
                                    .font(HeritageTypography.labelMedium)
                            }
                            if let projectCode = item.projectCode, !projectCode.isEmpty {
                                MetaChip(projectCode)
                                    .font(HeritageTypography.labelMedium)
                            }
                            if let year = item.publishedYear {
                                MetaChip(String(format: String(localized: "directory.yearFormat"), year))
                                    .font(HeritageTypography.labelMedium)
                            }
                        }

                        if let summary = item.summary, !summary.isEmpty {
                            Text(summary)
                                .font(HeritageTypography.bodyMedium)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                                .lineLimit(2)
                        }
                    }

                    Spacer()
                }
                .padding(14)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FlowLayout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

// MARK: - 筛选 Sheet

private struct DirectoryFilterSheet: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let region: String
    let category: String
    let year: String
    let listType: String
    let onApply: (String, String, String, String) -> Void
    let onClear: () -> Void
    let onDismiss: () -> Void

    @State private var regionText = ""
    @State private var categoryText = ""
    @State private var yearText = ""
    @State private var listTypeText = ""
    @State private var validationError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                filterField(label: "directory.filter.region", placeholder: "directory.filter.regionPlaceholder", text: $regionText)
                filterField(label: "directory.filter.category", placeholder: "directory.filter.categoryPlaceholder", text: $categoryText)
                filterField(label: "directory.filter.year", placeholder: "directory.filter.yearPlaceholder", text: $yearText)
                filterField(label: "directory.filter.listType", placeholder: "directory.filter.listTypePlaceholder", text: $listTypeText)

                if let validationError {
                    Text(validationError)
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.error)
                }

                HStack(spacing: 12) {
                    Button("action.clear") { onClear() }
                        .font(HeritageTypography.labelLarge)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colorScheme.surfaceContainerHigh)
                        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))

                    Button("action.apply") { validateAndApply() }
                        .font(HeritageTypography.labelLarge)
                        .foregroundStyle(colorScheme.onPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(colorScheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                }

                Spacer()
            }
            .padding(20)
            .background(colorScheme.background)
            .navigationTitle("nav.filter")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("nav.cancel") { onDismiss() }
                }
            }
            #endif
        }
        .onAppear {
            regionText = region
            categoryText = category
            yearText = year
            listTypeText = listType
        }
    }

    private func filterField(label: LocalizedStringKey, placeholder: LocalizedStringKey, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(HeritageTypography.labelLarge)
                .foregroundStyle(colorScheme.onSurface)
            TextField(placeholder, text: text)
                .font(HeritageTypography.bodyMedium)
                .textFieldStyle(.roundedBorder)
                .onChange(of: text.wrappedValue) { _, _ in validationError = nil }
        }
    }

    private func validateAndApply() {
        let y = yearText.trimmingCharacters(in: .whitespaces)
        if !y.isEmpty && (y.count != 4 || Int(y) == nil) {
            validationError = String(localized: "articles.filter.invalidYear")
            return
        }
        onApply(regionText, categoryText, yearText, listTypeText)
    }
}

// MARK: - Preview

#Preview {
    DirectoryView()
        .environment(SettingsManager.shared)
        .heritageTheme()
}
