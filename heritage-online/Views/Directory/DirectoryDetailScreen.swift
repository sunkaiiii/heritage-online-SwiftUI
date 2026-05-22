import SwiftUI

struct DirectoryDetailScreen: View {
    let itemId: String?
    let sourceId: String?
    let kind: DirectoryItemKind

    @State private var viewModel: DirectoryDetailViewModel
    @State private var showImagePreview = false
    @State private var previewIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(
        itemId: String? = nil,
        sourceId: String? = nil,
        kind: DirectoryItemKind = .nationalProject
    ) {
        self.itemId = itemId
        self.sourceId = sourceId
        self.kind = kind
        self._viewModel = State(initialValue: DirectoryDetailViewModel(
            itemId: itemId,
            sourceId: sourceId,
            kind: kind
        ))
    }

    private var detailToolbarButtons: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? Color(hex: "8F372F") : .secondary)
            }
            Button {
                Task { await viewModel.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
    }

    var previewUrls: [String] {
        guard let item = viewModel.item else { return [] }
        var urls: [String] = []
        if let coverUrl = item.coverImage?.previewUrl { urls.append(coverUrl) }
        for media in item.gallery {
            if let url = media.previewUrl { urls.append(url) }
        }
        for block in item.contentBlocks {
            if block.type == .image, let url = block.image?.previewUrl {
                urls.append(url)
            }
        }
        return urls
    }

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    if viewModel.isLoading {
                        LoadingContent()
                    } else if let error = viewModel.errorMessage {
                        ErrorContent(message: error) {
                            Task { await viewModel.refresh() }
                        }
                    } else if let item = viewModel.item {
                        if viewModel.isContentStale {
                            StaleContentWarning {
                                Task { await viewModel.refresh() }
                            }
                        }

                        heroSection(item: item)
                        factsSection(item: item)
                        descriptionSection(item: item)
                        gallerySection(item: item)
                        contentBlocksSection(item: item)
                        relatedSection(item: item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(Color(hex: "FCF8F5"))
        }
        .navigationTitle(String(localized: "directory_detail_title"))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                detailToolbarButtons
            }
            #else
            ToolbarItem(placement: .automatic) {
                detailToolbarButtons
            }
            #endif
        }
        .task {
            await viewModel.load()
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showImagePreview) {
            ImagePreviewView(
                imageUrls: previewUrls,
                initialIndex: previewIndex
            ) {
                showImagePreview = false
            }
        }
        #else
        .sheet(isPresented: $showImagePreview) {
            ImagePreviewView(
                imageUrls: previewUrls,
                initialIndex: previewIndex
            ) {
                showImagePreview = false
            }
        }
        #endif
    }

    @ViewBuilder
    private func heroSection(item: DirectoryItemDetailDto) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 4) {
                HeritageMetaChip(text: item.kind.label)
                if let category = item.category, !category.isEmpty {
                    HeritageMetaChip(text: category)
                }
            }

            if let coverUrl = item.coverImage?.previewUrl {
                HeritageDetailImage(
                    imageUrl: coverUrl,
                    fallbackText: String(localized: "brand_fallback")
                )
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onTapGesture {
                    previewIndex = 0
                    showImagePreview = true
                }
            }

            Text(item.title?.isEmpty == false ? item.title! : String(localized: "unnamed_directory_item"))
                .font(.title)
                .fontWeight(.bold)

            if let sourceUrl = item.sourceUrl, !sourceUrl.isEmpty, let url = URL(string: sourceUrl) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text(String(localized: "directory_open_source"))
                    }
                    .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private func factsSection(item: DirectoryItemDetailDto) -> some View {
        let facts: [HeritageFact] = [
            item.region?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_region"), value: item.region!) : nil,
            item.projectCode?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_project_code"), value: item.projectCode!) : nil,
            item.batch?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_batch"), value: item.batch!) : nil,
            item.publishedYear != nil ? HeritageFact(label: String(localized: "filter_field_year"), value: String(item.publishedYear!)) : nil,
            item.listType?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_list_type"), value: item.listType!) : nil,
            item.nominationType?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_nomination_type"), value: item.nominationType!) : nil,
            item.protectionUnit?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_protection_unit"), value: item.protectionUnit!) : nil,
        ].compactMap { $0 }

        if !facts.isEmpty {
            HeritageFactCard(facts: facts)
        }
    }

    @ViewBuilder
    private func descriptionSection(item: DirectoryItemDetailDto) -> some View {
        if let summary = item.summary, !summary.isEmpty {
            Text(summary)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
        }
    }

    @ViewBuilder
    private func gallerySection(item: DirectoryItemDetailDto) -> some View {
        if !item.gallery.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: String(localized: "directory_gallery_title"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(item.gallery.enumerated()), id: \.offset) { index, media in
                            if let url = media.previewUrl {
                                let idx = 1 + index
                                HeritageDetailImage(
                                    imageUrl: url,
                                    fallbackText: String(localized: "brand_fallback")
                                )
                                .frame(width: 160, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .onTapGesture {
                                    previewIndex = idx
                                    showImagePreview = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func contentBlocksSection(item: DirectoryItemDetailDto) -> some View {
        let offset = (item.coverImage?.previewUrl != nil ? 1 : 0) + item.gallery.count
        ForEach(Array(item.contentBlocks.enumerated()), id: \.offset) { idx, block in
            Group {
                switch block.type {
                case .heading:
                    if let text = block.text, !text.isEmpty {
                        Text(text)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.top, 4)
                    }
                case .text:
                    if let text = block.text, !text.isEmpty {
                        Text(text)
                            .font(.body)
                            .lineSpacing(4)
                    }
                case .image:
                    if let image = block.image, let imageUrl = image.previewUrl {
                        let previewIdx = offset + item.contentBlocks.prefix(idx).filter { $0.type == .image }.count
                        HeritageDetailImage(
                            imageUrl: imageUrl,
                            fallbackText: String(localized: "brand_fallback")
                        )
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .onTapGesture {
                            previewIndex = previewIdx
                            showImagePreview = true
                        }
                        .onAppear { }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func relatedSection(item: DirectoryItemDetailDto) -> some View {
        if !item.relatedProjects.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: String(localized: "directory_related_projects_title"))
                ForEach(Array(item.relatedProjects.enumerated()), id: \.offset) { _, ref in
                    if let title = ref.title {
                        HeritageReferenceCard(
                            title: title,
                            meta: ref.category ?? ref.region,
                            onClick: nil
                        )
                    }
                }
            }
        }

        if !item.relatedInheritors.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: String(localized: "directory_related_inheritors_title"))
                ForEach(Array(item.relatedInheritors.enumerated()), id: \.offset) { _, ref in
                    if let title = ref.title {
                        HeritageReferenceCard(
                            title: title,
                            meta: ref.category ?? ref.region,
                            onClick: nil
                        )
                    }
                }
            }
        }

        if !item.relatedDocuments.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: String(localized: "directory_related_documents_title"))
                ForEach(Array(item.relatedDocuments.enumerated()), id: \.offset) { _, ref in
                    if let title = ref.title {
                        HeritageReferenceCard(
                            title: title,
                            meta: ref.category,
                            onClick: nil
                        )
                    }
                }
            }
        }
    }
}
