import SwiftUI

struct InheritorDetailScreen: View {
    let inheritorId: String?
    let sourceId: String?

    @State private var viewModel: InheritorDetailViewModel
    @State private var showImagePreview = false
    @State private var previewIndex = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    init(
        inheritorId: String? = nil,
        sourceId: String? = nil
    ) {
        self.inheritorId = inheritorId
        self.sourceId = sourceId
        self._viewModel = State(initialValue: InheritorDetailViewModel(
            inheritorId: inheritorId,
            sourceId: sourceId
        ))
    }

    var previewUrls: [String] {
        guard let item = viewModel.item else { return [] }
        var urls: [String] = []
        if let coverUrl = item.coverImage?.previewUrl { urls.append(coverUrl) }
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
                        contentBlocksSection(item: item)
                        relatedSection(item: item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(Color(hex: "FCF8F5"))
        }
        .navigationTitle(String(localized: "inheritor_detail_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
        }
        .task {
            await viewModel.load()
        }
        .fullScreenCover(isPresented: $showImagePreview) {
            ImagePreviewView(
                imageUrls: previewUrls,
                initialIndex: previewIndex
            ) {
                showImagePreview = false
            }
        }
    }

    @ViewBuilder
    private func heroSection(item: InheritorDetailDto) -> some View {
        VStack(alignment: .leading, spacing: 14) {
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

            Text(item.name?.isEmpty == false ? item.name! : String(localized: "unnamed_inheritor"))
                .font(.title)
                .fontWeight(.bold)

            if let sourceUrl = item.sourceUrl, !sourceUrl.isEmpty, let url = URL(string: sourceUrl) {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text(String(localized: "inheritor_open_source"))
                    }
                    .font(.caption)
                }
            }
        }
    }

    @ViewBuilder
    private func factsSection(item: InheritorDetailDto) -> some View {
        let facts: [HeritageFact] = [
            item.gender?.isEmpty == false ? HeritageFact(label: String(localized: "filter_field_gender"), value: item.gender!) : nil,
            item.birthDateText?.isEmpty == false ? HeritageFact(label: String(localized: "inheritor_birth_date"), value: item.birthDateText!) : nil,
            item.ethnicity?.isEmpty == false ? HeritageFact(label: String(localized: "inheritor_ethnicity"), value: item.ethnicity!) : nil,
            item.category?.isEmpty == false ? HeritageFact(label: String(localized: "filter_field_category"), value: item.category!) : nil,
            item.region?.isEmpty == false ? HeritageFact(label: String(localized: "filter_field_region"), value: item.region!) : nil,
            item.batch?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_batch"), value: item.batch!) : nil,
            item.projectCode?.isEmpty == false ? HeritageFact(label: String(localized: "directory_field_project_code"), value: item.projectCode!) : nil,
            item.projectName?.isEmpty == false ? HeritageFact(label: String(localized: "inheritor_project_name"), value: item.projectName!) : nil,
        ].compactMap { $0 }

        if !facts.isEmpty {
            HeritageFactCard(facts: facts)
        }
    }

    @ViewBuilder
    private func descriptionSection(item: InheritorDetailDto) -> some View {
        if let description = item.description, !description.isEmpty {
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(6)
        }
    }

    @ViewBuilder
    private func contentBlocksSection(item: InheritorDetailDto) -> some View {
        let offset = item.coverImage?.previewUrl != nil ? 1 : 0
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
    private func relatedSection(item: InheritorDetailDto) -> some View {
        if !item.relatedProjects.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HeritageSectionHeader(title: String(localized: "inheritor_related_projects_title"))
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
                HeritageSectionHeader(title: String(localized: "inheritor_related_inheritors_title"))
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
    }
}
