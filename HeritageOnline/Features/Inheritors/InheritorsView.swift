import SwiftUI

/// 传承人列表页
/// 对齐 Android InheritorsScreen
struct InheritorsView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel = InheritorsViewModel()
    @State private var showFilterSheet = false

    var body: some View {
        PageBackground {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header
                    inheritorsHeader

                    // 搜索框
                    SearchField(
                        text: Binding(
                            get: { viewModel.uiState.searchKeywords },
                            set: { viewModel.updateSearchKeywords($0) }
                        ),
                        placeholder: "inheritors.searchPlaceholder"
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // 活跃筛选 chips
                    if viewModel.uiState.activeFilterCount > 0 {
                        activeFilterChips
                    }

                    // 列表内容
                    listContent
                }
                .padding(.bottom, 18)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            InheritorFilterSheet(
                region: viewModel.uiState.regionFilter,
                category: viewModel.uiState.categoryFilter,
                year: viewModel.uiState.yearFilter,
                gender: viewModel.uiState.genderFilter,
                onApply: { r, c, y, g in
                    viewModel.applyFilters(region: r, category: c, year: y, gender: g)
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

    private var inheritorsHeader: some View {
        PageHeader(
            titleKey: "page.inheritors",
            subtitleKey: "page.inheritors.subtitle",
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

    // MARK: - 活跃筛选 chips

    private var activeFilterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                filterChip(field: .region, value: viewModel.uiState.regionFilter)
                filterChip(field: .category, value: viewModel.uiState.categoryFilter)
                filterChip(field: .year, value: viewModel.uiState.yearFilter)
                filterChip(field: .gender, value: genderDisplayName(viewModel.uiState.genderFilter))
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }

    private func filterChip(field: InheritorFilterField, value: String) -> some View {
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

    private func genderDisplayName(_ gender: String) -> String {
        switch gender.trimmingCharacters(in: .whitespaces).lowercased() {
        case "male", "男": return String(localized: "inheritors.filter.gender.male")
        case "female", "女": return String(localized: "inheritors.filter.gender.female")
        default: return gender
        }
    }

    // MARK: - 列表内容

    @ViewBuilder
    private var listContent: some View {
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
                icon: isSearching ? "person.2.slash" : "tray",
                title: isSearching ? "inheritors.empty.search" : "inheritors.empty.default",
                message: isSearching ? "inheritors.empty.searchHint" : nil
            )
            .frame(minHeight: 300)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.uiState.items.enumerated()), id: \.element.id) { index, item in
                    InheritorRow(item: item)
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
}

// MARK: - 传承人卡片行

private struct InheritorRow: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: InheritorSummaryDTO

    var body: some View {
        NavigationLink(destination: InheritorDetailView(inheritorId: item.id)) {
            ContentCard {
                HStack(spacing: 12) {
                    // 左侧头像/占位
                    HeritageListImage(
                        asset: item.coverImage,
                        placeholderText: item.name ?? "E",
                        width: 92,
                        height: 92
                    )

                    // 右侧信息
                    VStack(alignment: .leading, spacing: 4) {
                        // 姓名
                        if let name = item.name, !name.isEmpty {
                            Text(name)
                                .font(HeritageTypography.titleMedium)
                                .foregroundStyle(colorScheme.onSurface)
                                .lineLimit(2)
                        }

                        // 项目名
                        if let projectName = item.projectName, !projectName.isEmpty {
                            Text(projectName)
                                .font(HeritageTypography.bodyMedium)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                                .lineLimit(1)
                        }

                        // Meta chips: gender, ethnicity, category, region, projectCode, batch
                        InheritorMetaChips(item: item)

                        // 简短摘要
                        if let description = item.description, !description.isEmpty {
                            Text(description)
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

// MARK: - 传承人 Meta Chips

private struct InheritorMetaChips: View {
    let item: InheritorSummaryDTO

    var body: some View {
        // 最多显示 3 个 chip
        let chips: [String?] = [
            item.gender.flatMap { genderLabel($0) },
            item.ethnicity,
            item.category,
            item.region,
            item.projectCode,
            item.batch,
        ]
        let nonEmpty = chips.compactMap { $0 }.filter { !$0.isEmpty }.prefix(3)

        if !nonEmpty.isEmpty {
            FlowLayout(spacing: 4) {
                ForEach(Array(nonEmpty.enumerated()), id: \.offset) { _, label in
                    MetaChip(label)
                        .font(HeritageTypography.labelMedium)
                }
            }
        }
    }

    private func genderLabel(_ gender: String) -> String? {
        switch gender.lowercased() {
        case "male", "男": return String(localized: "inheritors.filter.gender.male")
        case "female", "女": return String(localized: "inheritors.filter.gender.female")
        default: return gender.isEmpty ? nil : gender
        }
    }
}

// MARK: - 筛选 Sheet

private struct InheritorFilterSheet: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let region: String
    let category: String
    let year: String
    let gender: String
    let onApply: (String, String, String, String) -> Void
    let onClear: () -> Void
    let onDismiss: () -> Void

    @State private var regionText = ""
    @State private var categoryText = ""
    @State private var yearText = ""
    @State private var selectedGender = ""
    @State private var validationError: String?

    private let genderOptions = ["", "male", "female"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Region
                filterField(label: "inheritors.filter.region", placeholder: "directory.filter.regionPlaceholder", text: $regionText)

                // Category
                filterField(label: "inheritors.filter.category", placeholder: "directory.filter.categoryPlaceholder", text: $categoryText)

                // Year
                filterField(label: "inheritors.filter.year", placeholder: "inheritors.filter.yearPlaceholder", text: $yearText)

                // Gender picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("inheritors.filter.gender")
                        .font(HeritageTypography.labelLarge)
                        .foregroundStyle(colorScheme.onSurface)
                    HStack(spacing: 8) {
                        genderChip("", labelKey: "inheritors.filter.gender.all")
                        genderChip("male", labelKey: "inheritors.filter.gender.male")
                        genderChip("female", labelKey: "inheritors.filter.gender.female")
                    }
                }

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
            selectedGender = gender
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

    private func genderChip(_ value: String, labelKey: String) -> some View {
        Button {
            selectedGender = value
        } label: {
            MetaChip(String(localized: String.LocalizationValue(labelKey)), isSelected: selectedGender == value)
        }
        .buttonStyle(.plain)
    }

    private func validateAndApply() {
        let y = yearText.trimmingCharacters(in: .whitespaces)
        if !y.isEmpty && (y.count != 4 || Int(y) == nil) {
            validationError = String(localized: "articles.filter.invalidYear")
            return
        }
        onApply(regionText, categoryText, yearText, selectedGender)
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
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
        }
        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

// MARK: - Preview

#Preview {
    InheritorsView()
        .environment(SettingsManager.shared)
        .heritageTheme()
}
