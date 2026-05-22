import SwiftUI

struct DirectoryScreen: View {
    @Environment(ThemeManager.self) private var theme
    @Environment(LocalizationManager.self) private var loc
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var navigationPath: NavigationPath
    @State private var viewModel = DirectoryViewModel()
    @State private var showFilterSheet = false
    @State private var scrollID: String?
    @State private var draftRegionFilter = ""
    @State private var draftCategoryFilter = ""
    @State private var draftYearFilter = ""
    @State private var draftListTypeFilter = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerSection
                kindTabs
                searchField
                activeFilterChips
                statisticsSection
                contentSection
            }
            .padding(.bottom, 18)
        }
        .scrollPosition(id: $scrollID)
        .background(theme.background)
        .task {
            await viewModel.loadItems()
            await viewModel.loadStatistics()
        }
        .onChange(of: viewModel.selectedKind) { _, _ in
            Task {
                await viewModel.loadItems()
                await viewModel.loadStatistics()
            }
        }
        .onChange(of: viewModel.searchKeywords) { _, _ in
            Task { await viewModel.loadItems() }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheetView
                .presentationDetents([.large])
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            HeritagePageHeader(
                title: loc.localized("directory_header_title"),
                subtitle: loc.localized("directory_header_subtitle")
            )
            Spacer()
            HStack(spacing: 8) {
                HeritageFilterButton(
                    activeFilterCount: viewModel.activeFilterCount,
                    action: { showFilterSheet = true }
                )
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding(.trailing, 20)
        }
    }

    // MARK: - Kind Tabs

    private var kindTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DirectoryItemKind.allCases, id: \.self) { kind in
                    Button {
                        viewModel.selectedKind = kind
                    } label: {
                        Text(kind.label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedKind == kind
                                    ? theme.primaryContainer
                                    : theme.surfaceContainerHigh
                            )
                            .foregroundColor(
                                viewModel.selectedKind == kind
                                    ? theme.onPrimaryContainer
                                    : theme.onSurfaceVariant
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Search Field

    private var searchField: some View {
        HeritageSearchField(
            text: $viewModel.searchKeywords,
            placeholder: loc.localized("directory_search_placeholder")
        )
    }

    // MARK: - Active Filter Chips

    @ViewBuilder
    private var activeFilterChips: some View {
        let filters: [(String, String)] = [
            viewModel.regionFilter.isEmpty ? nil : (loc.localized("filter_field_region"), viewModel.regionFilter),
            viewModel.categoryFilter.isEmpty ? nil : (loc.localized("filter_field_category"), viewModel.categoryFilter),
            viewModel.yearFilter.isEmpty ? nil : (loc.localized("filter_field_year"), viewModel.yearFilter),
            viewModel.listTypeFilter.isEmpty ? nil : (loc.localized("directory_field_list_type"), viewModel.listTypeFilter),
        ].compactMap { $0 }

        if !filters.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(filters, id: \.0) { label, value in
                    HStack(spacing: 4) {
                        HeritageMetaChip(text: "\(label): \(value)")
                        Button {
                            switch label {
                            case loc.localized("filter_field_region"): viewModel.regionFilter = ""
                            case loc.localized("filter_field_category"): viewModel.categoryFilter = ""
                            case loc.localized("filter_field_year"): viewModel.yearFilter = ""
                            case loc.localized("directory_field_list_type"): viewModel.listTypeFilter = ""
                            default: break
                            }
                            Task { await viewModel.loadItems() }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Statistics

    @ViewBuilder
    private var statisticsSection: some View {
        if let stats = viewModel.statistics {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: loc.localized("directory_statistics_title"))
                HeritageContentCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(loc.localized("directory_statistics_total")): \(stats.total)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(theme.primary)

                        ForEach(Array(stats.dimensions.enumerated()), id: \.offset) { _, dimension in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dimension.dimension ?? "")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                ForEach(Array(dimension.items.prefix(10).enumerated()), id: \.offset) { _, item in
                                    HStack {
                                        Text(item.name ?? item.key ?? "")
                                            .font(.body)
                                        Spacer()
                                        Text("\(item.value)")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(14)
                }
            }
            .padding(.horizontal, 20)
        } else if viewModel.isLoadingStatistics {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            LoadingContent()
        } else if let error = viewModel.errorMessage {
            ErrorContent(message: error) {
                Task { await viewModel.loadItems() }
            }
        } else if viewModel.items.isEmpty {
            EmptyContent(message: loc.localized("directory_empty_message")) {
                Task { await viewModel.loadItems() }
            }
        } else {
            if horizontalSizeClass == .regular {
            let columns = [GridItem(.adaptive(minimum: 300))]
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                    DirectoryItemRow(item: item) {
                        navigationPath.append(DirectoryNavigationDestination.directoryDetail(id: item.id, sourceId: nil, kind: item.kind))
                    }
                        .onAppear {
                            if index == viewModel.items.count - 3 {
                                Task { await viewModel.loadMoreItems() }
                            }
                        }
                }
            }
            .padding(.horizontal, 20)
            } else {
            ForEach(viewModel.items) { item in
                DirectoryItemRow(item: item) {
                        navigationPath.append(DirectoryNavigationDestination.directoryDetail(id: item.id, sourceId: nil, kind: item.kind))
                    }
                    .padding(.horizontal, 20)
            }
            }

            if viewModel.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Filter Sheet

    private var filterSheetView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(loc.localized("filter_title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 24)

                filterField(label: loc.localized("filter_field_region"), placeholder: loc.localized("filter_placeholder_region"), text: $draftRegionFilter)
                filterField(label: loc.localized("filter_field_category"), placeholder: loc.localized("directory_field_category"), text: $draftCategoryFilter)
                filterField(label: loc.localized("filter_field_year"), placeholder: loc.localized("filter_placeholder_year"), text: $draftYearFilter)
                filterField(label: loc.localized("directory_field_list_type"), placeholder: loc.localized("directory_field_list_type"), text: $draftListTypeFilter)

                HStack {
                    Button("filter_clear") {
                        viewModel.regionFilter = ""
                        viewModel.categoryFilter = ""
                        viewModel.yearFilter = ""
                        viewModel.listTypeFilter = ""
                        showFilterSheet = false
                        Task { await viewModel.loadItems() }
                    }
                    Spacer()
                    Button("filter_apply") {
                        viewModel.regionFilter = draftRegionFilter
                        viewModel.categoryFilter = draftCategoryFilter
                        viewModel.yearFilter = draftYearFilter
                        viewModel.listTypeFilter = draftListTypeFilter
                        showFilterSheet = false
                        Task { await viewModel.loadItems() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            draftRegionFilter = viewModel.regionFilter
            draftCategoryFilter = viewModel.categoryFilter
            draftYearFilter = viewModel.yearFilter
            draftListTypeFilter = viewModel.listTypeFilter
        }
    }

    private func filterField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

// MARK: - Directory Item Row

struct DirectoryItemRow: View {
    @Environment(LocalizationManager.self) private var loc
    let item: DirectoryItemSummaryDto
    let onClick: (() -> Void)?

    var imageUrl: String? {
        item.coverImage?.previewUrl
    }

    var body: some View {
        HeritageListCard(
            onClick: onClick,
            image: {
                HeritageListImage(
                    imageUrl: imageUrl,
                    fallbackText: loc.localized("brand_fallback")
                )
                .frame(width: 104, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            },
            text: {
                HStack(spacing: 4) {
                    HeritageMetaChip(text: item.kind.label)
                    if let category = item.category, !category.isEmpty {
                        HeritageMetaChip(text: category)
                    }
                }
                Text(item.title?.isEmpty == false ? item.title! : loc.localized("unnamed_directory_item"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                if let summary = item.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        )
    }
}
