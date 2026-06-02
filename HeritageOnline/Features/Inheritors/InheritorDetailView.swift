import SwiftUI

/// 传承人详情页
/// 对齐 Android InheritorDetailScreen
struct InheritorDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: InheritorDetailViewModel

    @State private var showImagePreview = false
    @State private var previewImageURLs: [String] = []
    @State private var previewIndex = 0
    @State private var showSourceError = false

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil,
        repository: HeritageRepository = DefaultHeritageRepository()
    ) {
        _viewModel = State(initialValue: InheritorDetailViewModel(
            inheritorId: inheritorId,
            sourceId: sourceId,
            repository: repository
        ))
    }

    var body: some View {
        ZStack {
            if viewModel.uiState.isLoading && viewModel.uiState.item == nil {
                LoadingPlaceholder()
            } else if let error = viewModel.uiState.error, viewModel.uiState.item == nil {
                detailErrorView(error)
            } else if let item = viewModel.uiState.item {
                InheritorDetailContent(
                    item: item,
                    isContentStale: viewModel.uiState.isContentStale,
                    isFavorite: viewModel.uiState.isFavorite,
                    onToggleFavorite: { viewModel.toggleFavorite() },
                    onOpenSource: { openSourceURL($0) },
                    onPreviewImage: { urls, index in
                        previewImageURLs = urls
                        previewIndex = index
                        showImagePreview = true
                    },
                    onRefresh: { Task { await viewModel.refresh() } }
                )
            }
        }
        .navigationTitle("inheritorDetail.title")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").foregroundStyle(colorScheme.onSurface)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button { viewModel.toggleFavorite() } label: {
                        Image(systemName: viewModel.uiState.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.uiState.isFavorite ? colorScheme.error : colorScheme.onSurfaceVariant)
                    }
                    Button { Task { await viewModel.refresh() } } label: {
                        Image(systemName: "arrow.clockwise").foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                }
            }
        }
        #endif
        .task { await viewModel.refresh() }
        #if os(iOS)
        .fullScreenCover(isPresented: $showImagePreview) {
            ImagePreviewOverlay(imageUrls: previewImageURLs, initialIndex: previewIndex, onDismiss: { showImagePreview = false })
        }
        #elseif os(macOS)
        .sheet(isPresented: $showImagePreview) {
            ImagePreviewOverlay(imageUrls: previewImageURLs, initialIndex: previewIndex, onDismiss: { showImagePreview = false })
        }
        #endif
        .overlay(alignment: .bottom) {
            if showSourceError {
                sourceErrorSnackbar
            }
        }
    }

    private func detailErrorView(_ error: AppError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 48)).foregroundStyle(colorScheme.onSurfaceVariant)
            Text(LocalizedStringKey(error.localizedDescription)).font(HeritageTypography.bodyMedium).foregroundStyle(colorScheme.onSurfaceVariant).multilineTextAlignment(.center)
            Button("action.retry") { Task { await viewModel.refresh() } }.font(HeritageTypography.labelLarge).foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(40)
    }

    private func openSourceURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { showSourceError = true; return }
        #if os(iOS)
        UIApplication.shared.open(url) { if !$0 { showSourceError = true } }
        #elseif os(macOS)
        if !NSWorkspace.shared.open(url) { showSourceError = true }
        #endif
    }

    private var sourceErrorSnackbar: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 14)).foregroundStyle(colorScheme.onErrorContainer)
            Text("articleDetail.sourceOpenFailed").font(HeritageTypography.bodyMedium).foregroundStyle(colorScheme.onErrorContainer)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(colorScheme.errorContainer).clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
        .padding(.horizontal, 20).padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onTapGesture { showSourceError = false }
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 3) { withAnimation { showSourceError = false } } }
    }
}

// MARK: - 传承人详情内容

private struct InheritorDetailContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: InheritorDetailDTO
    let isContentStale: Bool
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onOpenSource: (String) -> Void
    let onPreviewImage: ([String], Int) -> Void
    let onRefresh: () -> Void

    private var previewURLs: [String] {
        ImagePreviewUrl.collect(
            coverImage: item.coverImage,
            gallery: [],
            contentBlocks: item.contentBlocks
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                // 过期内容提示
                if isContentStale {
                    staleContentBanner
                }

                // Hero 区
                InheritorHero(
                    item: item,
                    onOpenSource: onOpenSource,
                    onPreviewCover: {
                        if !previewURLs.isEmpty { onPreviewImage(previewURLs, 0) }
                    }
                )

                // FactCard
                InheritorFacts(item: item)

                // Description
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(HeritageTypography.bodyLarge)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineSpacing(6)
                }

                // Content Blocks
                if !item.contentBlocks.isEmpty {
                    ForEach(Array(item.contentBlocks.enumerated()), id: \.offset) { blockIndex, block in
                        let imageBlockIndex = (item.coverImage != nil ? 1 : 0) + item.contentBlocks.prefix(blockIndex).filter { $0.type == .image }.count
                        ContentBlockView(
                            block: block,
                            previewURLs: previewURLs,
                            imageIndex: block.type == .image ? imageBlockIndex : nil,
                            onPreviewImage: onPreviewImage
                        )
                    }
                }

                // 空内容兜底
                if item.contentBlocks.isEmpty && (item.description == nil || item.description?.isEmpty == true) {
                    Text("articleDetail.emptyContent")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                }

                // 相关项目（跳转名录详情）
                if !item.relatedProjects.isEmpty {
                    SectionHeader(title: String(localized: "inheritorDetail.relatedProjects"))
                    ForEach(Array(item.relatedProjects.enumerated()), id: \.offset) { _, ref in
                        if let sourceId = ref.sourceId, !sourceId.isEmpty {
                            NavigationLink {
                                DirectoryDetailView(sourceId: sourceId, kind: DirectoryItemKind(rawValue: ref.kind ?? "nationalProject") ?? .nationalProject)
                            } label: {
                                referenceCard(ref)
                            }
                            .buttonStyle(.plain)
                        } else {
                            referenceCard(ref)
                        }
                    }
                }

                // 相关传承人（跳转传承人详情）
                if !item.relatedInheritors.isEmpty {
                    SectionHeader(title: String(localized: "inheritorDetail.relatedInheritors"))
                    ForEach(Array(item.relatedInheritors.enumerated()), id: \.offset) { _, ref in
                        if let sourceId = ref.sourceId, !sourceId.isEmpty {
                            NavigationLink {
                                InheritorDetailView(sourceId: sourceId)
                            } label: {
                                referenceCard(ref)
                            }
                            .buttonStyle(.plain)
                        } else {
                            referenceCard(ref)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(colorScheme.background)
    }

    private var staleContentBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 14)).foregroundStyle(colorScheme.onTertiaryContainer)
            Text("articleDetail.staleContent").font(HeritageTypography.bodyMedium).foregroundStyle(colorScheme.onTertiaryContainer)
            Spacer()
            Button("action.refresh") { onRefresh() }.font(HeritageTypography.labelLarge).foregroundStyle(colorScheme.tertiary)
        }
        .padding(12).background(colorScheme.tertiaryContainer).clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }

    private func referenceCard(_ ref: DirectoryReferenceDTO) -> some View {
        ContentCard {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = ref.title, !title.isEmpty {
                        Text(title)
                            .font(HeritageTypography.titleMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(2)
                    }
                    let metaParts = [
                        ref.kind.flatMap { ContentLabels.localizedDirectoryKind($0) }.map { String(localized: String.LocalizationValue($0)) },
                        ref.category,
                        ref.region,
                        ref.publishedYear.map { String(format: String(localized: "directory.yearFormat"), $0) }
                    ].compactMap { $0 }.filter { !$0.isEmpty }
                    if !metaParts.isEmpty {
                        Text(metaParts.joined(separator: " · "))
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14)).foregroundStyle(colorScheme.onSurfaceVariant)
            }
            .padding(14)
        }
    }
}

// MARK: - 传承人 Hero 区

private struct InheritorHero: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: InheritorDetailDTO
    let onOpenSource: (String) -> Void
    let onPreviewCover: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Name
            if let name = item.name, !name.isEmpty {
                Text(name)
                    .font(HeritageTypography.headlineMedium)
                    .foregroundStyle(colorScheme.onSurface)
            }

            // Project name
            if let projectName = item.projectName, !projectName.isEmpty {
                Text(projectName)
                    .font(HeritageTypography.titleMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
            }

            // Meta chips: gender, ethnicity, category, region
            FlowLayout(spacing: 6) {
                if let gender = item.gender, !gender.isEmpty {
                    MetaChip(genderLabel(gender))
                }
                if let ethnicity = item.ethnicity, !ethnicity.isEmpty {
                    MetaChip(ethnicity)
                }
                if let category = item.category, !category.isEmpty {
                    MetaChip(category)
                }
                if let region = item.region, !region.isEmpty {
                    MetaChip(region)
                }
            }

            // 查看原文
            if let sourceUrl = item.sourceUrl, !sourceUrl.isEmpty {
                Button { onOpenSource(sourceUrl) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.square").font(.system(size: 14))
                        Text("articleDetail.viewSource").font(HeritageTypography.labelLarge)
                    }
                    .foregroundStyle(colorScheme.primary)
                }
                .buttonStyle(.plain)
            }

            // 封面图
            if let coverImage = item.coverImage {
                let urlString = ImagePreviewUrl.previewUrl(from: coverImage)
                HeritageDetailImage(
                    urlString: urlString,
                    placeholderText: item.name ?? "E",
                    contentMode: .fit,
                    onTap: onPreviewCover
                )
                .aspectRatio(4/3, contentMode: .fit)
            }
        }
    }

    private func genderLabel(_ gender: String) -> String {
        switch gender.lowercased() {
        case "male", "男": return String(localized: "inheritors.filter.gender.male")
        case "female", "女": return String(localized: "inheritors.filter.gender.female")
        default: return gender
        }
    }
}

// MARK: - 传承人 FactCard

private struct InheritorFacts: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: InheritorDetailDTO

    var body: some View {
        let facts: [(LocalizedStringKey, String?)] = [
            ("inheritorDetail.field.projectName", item.projectName),
            ("inheritorDetail.field.projectCode", item.projectCode),
            ("inheritorDetail.field.birthDate", item.birthDateText),
            ("inheritorDetail.field.batch", item.batch),
        ]
        let nonEmpty = facts.filter { $0.1 != nil && !($0.1?.isEmpty ?? true) }

        if !nonEmpty.isEmpty {
            ContentCard {
                VStack(spacing: 10) {
                    ForEach(Array(nonEmpty.enumerated()), id: \.offset) { _, fact in
                        HStack(alignment: .top) {
                            Text(fact.0)
                                .font(HeritageTypography.bodyMedium)
                                .foregroundStyle(colorScheme.primary)
                                .frame(width: 100, alignment: .leading)
                            Text(fact.1 ?? "")
                                .font(HeritageTypography.bodyMedium)
                                .foregroundStyle(colorScheme.onSurface)
                            Spacer()
                        }
                    }
                }
                .padding(14)
            }
        }
    }
}

// MARK: - 内容块视图

private struct ContentBlockView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let block: ArticleContentBlockDTO
    let previewURLs: [String]
    let imageIndex: Int?
    let onPreviewImage: ([String], Int) -> Void

    var body: some View {
        switch block.type {
        case .heading:
            if let text = block.text, !text.isEmpty {
                SectionHeader(title: text)
            }
        case .text:
            if let text = block.text, !text.isEmpty {
                if isStandaloneSectionTitle(text) {
                    Text(text).font(HeritageTypography.titleMedium).fontWeight(.semibold).foregroundStyle(colorScheme.onSurface)
                } else {
                    Text(text).font(HeritageTypography.bodyLarge).foregroundStyle(colorScheme.onSurface).lineSpacing(6)
                }
            }
        case .image:
            if let image = block.image {
                let urlString = ImagePreviewUrl.previewUrl(from: image)
                HeritageDetailImage(
                    urlString: urlString,
                    placeholderText: "E",
                    contentMode: .fit,
                    onTap: {
                        if let urlString, let imageIndex, let idx = previewURLs.firstIndex(of: urlString) {
                            onPreviewImage(previewURLs, idx)
                        }
                    }
                )
                .aspectRatio(4/3, contentMode: .fit)
            }
        }
    }

    private func isStandaloneSectionTitle(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if trimmed.hasSuffix("：") || trimmed.hasSuffix(":") { return trimmed.count <= 32 }
        let sentenceEnders: [Character] = ["。", "！", "？", ".", "!", "?", "；", ";"]
        let hasSentenceEnder = trimmed.contains(where: { sentenceEnders.contains($0) })
        return !hasSentenceEnder && trimmed.count <= 18
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
    NavigationStack {
        InheritorDetailView(inheritorId: "test")
    }
    .environment(SettingsManager.shared)
    .heritageTheme()
}
