import SwiftUI

struct InheritorsScreen: View {
    @State private var viewModel = InheritorsViewModel()
    @State private var showFilterSheet = false
    @State private var draftRegionFilter = ""
    @State private var draftCategoryFilter = ""
    @State private var draftYearFilter = ""
    @State private var draftGenderFilter = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                headerSection
                searchField
                activeFilterChips
                genderFilterChip
                contentSection
            }
            .padding(.bottom, 18)
        }
        .background(Color(hex: "FCF8F5"))
        .task {
            await viewModel.loadItems()
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
                title: String(localized: "inheritors_title"),
                subtitle: String(localized: "inheritors_subtitle")
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

    // MARK: - Search Field

    private var searchField: some View {
        HeritageSearchField(
            text: $viewModel.searchKeywords,
            placeholder: String(localized: "inheritors_search_placeholder")
        )
    }

    // MARK: - Active Filter Chips

    @ViewBuilder
    private var activeFilterChips: some View {
        let filters: [(String, String)] = [
            viewModel.regionFilter.isEmpty ? nil : (String(localized: "filter_field_region"), viewModel.regionFilter),
            viewModel.categoryFilter.isEmpty ? nil : (String(localized: "filter_field_category"), viewModel.categoryFilter),
            viewModel.yearFilter.isEmpty ? nil : (String(localized: "filter_field_year"), viewModel.yearFilter),
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

    // MARK: - Gender Filter Chip

    @ViewBuilder
    private var genderFilterChip: some View {
        if !viewModel.genderFilter.isEmpty {
            HStack {
                HeritageMetaChip(text: "\(String(localized: "filter_field_gender")): \(viewModel.genderFilter)")
                Button {
                    viewModel.genderFilter = ""
                    Task { await viewModel.loadItems() }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 20)
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
            EmptyContent(message: String(localized: "inheritors_empty_message")) {
                Task { await viewModel.loadItems() }
            }
        } else {
            ForEach(viewModel.items) { inheritor in
                InheritorRow(inheritor: inheritor)
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

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "filter_field_gender"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("", selection: $draftGenderFilter) {
                        Text(String(localized: "filter_gender_any")).tag("")
                        Text(String(localized: "filter_gender_male")).tag("男")
                        Text(String(localized: "filter_gender_female")).tag("女")
                    }
                    .pickerStyle(.segmented)
                }

                HStack {
                    Button(String(localized: "filter_clear")) {
                        viewModel.regionFilter = ""
                        viewModel.categoryFilter = ""
                        viewModel.yearFilter = ""
                        viewModel.genderFilter = ""
                        showFilterSheet = false
                        Task { await viewModel.loadItems() }
                    }
                    Spacer()
                    Button(String(localized: "filter_apply")) {
                        viewModel.regionFilter = draftRegionFilter
                        viewModel.categoryFilter = draftCategoryFilter
                        viewModel.yearFilter = draftYearFilter
                        viewModel.genderFilter = draftGenderFilter
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
            draftGenderFilter = viewModel.genderFilter
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

// MARK: - Inheritor Row

struct InheritorRow: View {
    let inheritor: InheritorSummaryDto

    var imageUrl: String? {
        inheritor.coverImage?.previewUrl
    }

    var body: some View {
        HeritageListCard(
            image: {
                HeritageListImage(
                    imageUrl: imageUrl,
                    fallbackText: String(localized: "brand_fallback")
                )
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            },
            text: {
                Text(inheritor.name?.isEmpty == false ? inheritor.name! : String(localized: "unnamed_inheritor"))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)

                if let projectName = inheritor.projectName, !projectName.isEmpty {
                    Text(projectName)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }

                HStack(spacing: 4) {
                    if let category = inheritor.category, !category.isEmpty {
                        HeritageMetaChip(text: category)
                    }
                    if let region = inheritor.region, !region.isEmpty {
                        HeritageMetaChip(text: region)
                    }
                    if let batch = inheritor.batch, !batch.isEmpty {
                        HeritageMetaChip(text: batch)
                    }
                }

                if let description = inheritor.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        )
    }
}
