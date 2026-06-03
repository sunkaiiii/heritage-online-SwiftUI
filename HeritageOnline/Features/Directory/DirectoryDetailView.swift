import SwiftUI

/// 名录详情页
/// 对齐 Android DirectoryDetailScreen
struct DirectoryDetailView: View {
    @Environment(\.heritageColorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: DirectoryDetailViewModel

    @State private var showImagePreview = false
    @State private var previewImageURLs: [String] = []
    @State private var previewIndex = 0
    @State private var showSourceError = false

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject,
        repository: HeritageRepository = DefaultHeritageRepository()
    ) {
        _viewModel = State(initialValue: DirectoryDetailViewModel(
            itemId: itemId,
            sourceId: sourceId,
            kind: kind,
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
                DirectoryDetailContent(
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
        .navigationTitle("directoryDetail.title")
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
            Text(verbatim: error.localizedDescription).font(HeritageTypography.bodyMedium).foregroundStyle(colorScheme.onSurfaceVariant).multilineTextAlignment(.center)
            Button("action.retry") { Task { await viewModel.refresh() } }.font(HeritageTypography.labelLarge).foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).padding(40)
    }

    private func openSourceURL(_ urlString: String) {
        guard let url = ExternalURLValidator.httpURL(from: urlString) else { showSourceError = true; return }
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

// MARK: - 名录详情内容

private struct DirectoryDetailContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DirectoryItemDetailDTO
    let isContentStale: Bool
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let onOpenSource: (String) -> Void
    let onPreviewImage: ([String], Int) -> Void
    let onRefresh: () -> Void

    /// 收集所有可预览图片 URL（封面 + 图库 + 内容块图片）
    private var previewURLs: [String] {
        ImagePreviewUrl.collect(
            coverImage: item.coverImage,
            gallery: item.gallery,
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
                DirectoryHero(
                    item: item,
                    onOpenSource: onOpenSource,
                    onPreviewCover: {
                        if !previewURLs.isEmpty { onPreviewImage(previewURLs, 0) }
                    }
                )

                // FactCard
                DirectoryFacts(item: item)

                // 图库
                if !item.gallery.isEmpty {
                    SectionHeader(title: String(localized: "directoryDetail.gallery"))
                    galleryStrip
                }

                // Content Blocks
                let galleryOffset = item.coverImage != nil ? 1 : 0
                let imageStartIndex = galleryOffset + item.gallery.count
                ForEach(Array(item.contentBlocks.enumerated()), id: \.offset) { blockIndex, block in
                    let imageBlockIndex = imageStartIndex + item.contentBlocks.prefix(blockIndex).filter { $0.type == .image }.count
                    DetailContentBlockView(
                        block: block,
                        previewURLs: previewURLs,
                        imageIndex: block.type == .image ? imageBlockIndex : nil,
                        onPreviewImage: onPreviewImage
                    )
                }

                // 空内容兜底
                if item.contentBlocks.isEmpty && (item.summary == nil || item.summary?.isEmpty == true) {
                    Text("articleDetail.emptyContent")
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 40)
                }

                // 相关项目
                referenceSection(
                    title: String(localized: "directoryDetail.relatedProjects"),
                    references: item.relatedProjects,
                    isNavigable: true
                )

                // 相关传承人
                if !item.relatedInheritors.isEmpty {
                    SectionHeader(title: String(localized: "directoryDetail.relatedInheritors"))
                    ForEach(Array(item.relatedInheritors.enumerated()), id: \.offset) { _, ref in
                        if let sourceId = ref.sourceId, !sourceId.isEmpty {
                            NavigationLink {
                                InheritorDetailView(sourceId: sourceId)
                            } label: {
                                DirectoryReferenceCard(ref: ref)
                            }
                            .buttonStyle(.plain)
                        } else {
                            DirectoryReferenceCard(ref: ref)
                        }
                    }
                }

                // 相关文献
                referenceSection(
                    title: String(localized: "directoryDetail.relatedDocuments"),
                    references: item.relatedDocuments,
                    isNavigable: false
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
        }
        .background(colorScheme.background)
    }

    /// 过期内容提示
    private var staleContentBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 14)).foregroundStyle(colorScheme.onTertiaryContainer)
            Text("articleDetail.staleContent").font(HeritageTypography.bodyMedium).foregroundStyle(colorScheme.onTertiaryContainer)
            Spacer()
            Button("action.refresh") { onRefresh() }.font(HeritageTypography.labelLarge).foregroundStyle(colorScheme.tertiary)
        }
        .padding(12).background(colorScheme.tertiaryContainer).clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
    }

    /// 图库横向滚动
    private var galleryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(Array(item.gallery.enumerated()), id: \.offset) { _, image in
                    let urlString = ImagePreviewUrl.previewUrl(from: image)
                    HeritageDetailImage(
                        urlString: urlString,
                        placeholderText: "E",
                        contentMode: .fit,
                        onTap: {
                            if let urlString, let idx = previewURLs.firstIndex(of: urlString) {
                                onPreviewImage(previewURLs, idx)
                            }
                        }
                    )
                    .frame(width: 280)
                    .aspectRatio(4/3, contentMode: .fit)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    /// 相关内容区块
    @ViewBuilder
    private func referenceSection(title: String, references: [DirectoryReferenceDTO], isNavigable: Bool) -> some View {
        if !references.isEmpty {
            SectionHeader(title: title)
            ForEach(Array(references.enumerated()), id: \.offset) { _, ref in
                if isNavigable && ref.sourceId != nil && !(ref.sourceId?.isEmpty ?? true) {
                    NavigationLink {
                        DirectoryDetailView(sourceId: ref.sourceId, kind: DirectoryItemKind(rawValue: ref.kind ?? "nationalProject") ?? .nationalProject)
                    } label: {
                        DirectoryReferenceCard(ref: ref)
                    }
                    .buttonStyle(.plain)
                } else {
                    DirectoryReferenceCard(ref: ref)
                }
            }
        }
    }
}

// MARK: - 名录 Hero 区

private struct DirectoryHero: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DirectoryItemDetailDTO
    let onOpenSource: (String) -> Void
    let onPreviewCover: () -> Void

    private var kindLabel: String? {
        guard let key = ContentLabels.localizedDirectoryKind(item.kind) else { return nil }
        return String(localized: String.LocalizationValue(key))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Kind chip
            if let kindLabel {
                MetaChip(kindLabel)
            }

            // Title
            if let title = item.title, !title.isEmpty {
                Text(title)
                    .font(HeritageTypography.headlineMedium)
                    .foregroundStyle(colorScheme.onSurface)
            }

            // Summary（Hero 区内，title 之后）
            if let summary = item.summary, !summary.isEmpty {
                Text(summary)
                    .font(HeritageTypography.bodyLarge)
                    .foregroundStyle(colorScheme.onSurface)
                    .lineSpacing(6)
            }

            // Meta chips: category, region, publishedYear, listType
            FlowLayout(spacing: 6) {
                if let category = item.category, !category.isEmpty {
                    MetaChip(category)
                }
                if let region = item.region, !region.isEmpty {
                    MetaChip(region)
                }
                if let year = item.publishedYear {
                    MetaChip(String(format: String(localized: "directory.yearFormat"), year))
                }
                if let listType = item.listType, !listType.isEmpty {
                    MetaChip(listType)
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
                    placeholderText: item.title ?? "E",
                    contentMode: .fit,
                    onTap: onPreviewCover
                )
                .aspectRatio(4/3, contentMode: .fit)
            }
        }
    }
}

// MARK: - 名录 FactCard

private struct DirectoryFacts: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: DirectoryItemDetailDTO

    var body: some View {
        let facts: [(LocalizedStringKey, String?)] = [
            ("directoryDetail.field.projectCode", item.projectCode),
            ("directoryDetail.field.batch", item.batch),
            ("directoryDetail.field.protectionUnit", item.protectionUnit),
            ("directoryDetail.field.nominationType", item.nominationType),
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

// MARK: - Preview

#Preview {
    NavigationStack {
        DirectoryDetailView(itemId: "test")
    }
    .environment(SettingsManager.shared)
    .heritageTheme()
}
