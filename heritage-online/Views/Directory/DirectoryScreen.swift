import SwiftUI

struct DirectoryScreen: View {
    @Binding var navigationPath: NavigationPath
    @State private var viewModel = DirectoryViewModel()
    @State private var showFilterSheet = false
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
        .background(Color(hex: "FCF8F5"))
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
                title: String(localized: "directory_header_title"),
                subtitle: String(localized: "directory_header_subtitle")
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
                                    ? Color(hex: "FFDAD4")
                                    : Color(hex: "EFE3DE")
                            )
                            .foregroundColor(
                                viewModel.selectedKind == kind
                                    ? Color(hex: "3A0905")
                                    : Color(hex: "51443F")
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Search Field

    private var searchField: some View {
        HeritageSearchField(
            text: $viewModel.searchKeywords,
            placeholder: String(localized: "directory_search_placeholder")
        )
    }

    // MARK: - Active Filter Chips

    @ViewBuilder
    private var activeFilterChips: some View {
        let filters: [(String, String)] = [
            viewModel.regionFilter.isEmpty ? nil : (String(localized: "filter_field_region"), viewModel.regionFilter),
            viewModel.categoryFilter.isEmpty ? nil : (String(localized: "filter_field_category"), viewModel.categoryFilter),
            viewModel.yearFilter.isEmpty ? nil : (String(localized: "filter_field_year"), viewModel.yearFilter),
            viewModel.listTypeFilter.isEmpty ? nil : (String(localized: "directory_field_list_type"), viewModel.listTypeFilter),
        ].compactMap { $0 }

        if !filters.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(filters, id: \.0) { label, value in
                    HStack(spacing: 4) {
                        HeritageMetaChip(text: "\(label): \(value)")
                        Button {
                            switch label {
                            case String(localized: "filter_field_region"): viewModel.regionFilter = ""
                            case String(localized: "filter_field_category"): viewModel.categoryFilter = ""
                            case String(localized: "filter_field_year"): viewModel.yearFilter = ""
                            case String(localized: "directory_field_list_type"): viewModel.listTypeFilter = ""
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
                HeritageSectionHeader(title: String(localized: "directory_statistics_title"))
                HeritageContentCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(String(localized: "directory_statistics_total")): \(stats.total)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "8F372F"))

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
            EmptyContent(message: String(localized: "directory_empty_message")) {
                Task { await viewModel.loadItems() }
            }
        } else {
            ForEach(viewModel.items) { item in
                DirectoryItemRow(item: item) {
                        navigationPath.append(DirectoryNavigationDestination.directoryDetail(id: item.id, sourceId: nil, kind: item.kind))
                    }
                    .padding(.horizontal, 20)
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
                Text(String(localized: "filter_title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 24)

                filterField(label: String(localized: "filter_field_region"), placeholder: String(localized: "filter_placeholder_region"), text: $draftRegionFilter)
                filterField(label: String(localized: "filter_field_category"), placeholder: String(localized: "directory_field_category"), text: $draftCategoryFilter)
                filterField(label: String(localized: "filter_field_year"), placeholder: String(localized: "filter_placeholder_year"), text: $draftYearFilter)
                filterField(label: String(localized: "directory_field_list_type"), placeholder: String(localized: "directory_field_list_type"), text: $draftListTypeFilter)

                HStack {
                    Button(String(localized: "filter_clear")) {
                        viewModel.regionFilter = ""
                        viewModel.categoryFilter = ""
                        viewModel.yearFilter = ""
                        viewModel.listTypeFilter = ""
                        showFilterSheet = false
                        Task { await viewModel.loadItems() }
                    }
                    Spacer()
                    Button(String(localized: "filter_apply")) {
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
                    fallbackText: String(localized: "brand_fallback")
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
                Text(item.title?.isEmpty == false ? item.title! : String(localized: "unnamed_directory_item"))
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
