import SwiftUI

/// 地区图谱首页
/// 对齐 Android RegionAtlasScreen
/// 展示地区卡片网格和总计信息
struct RegionAtlasView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    @State private var viewModel = RegionAtlasViewModel()

    /// 子导航状态
    @State private var navigateToRegion: String?

    var body: some View {
        PageBackground {
            ZStack {
                if viewModel.isLoading && viewModel.atlas == nil {
                    LoadingPlaceholder()
                } else if let error = viewModel.error, viewModel.atlas == nil {
                    RegionAtlasErrorContent(
                        error: error,
                        onRetry: { viewModel.loadAtlas() }
                    )
                } else if let atlas = viewModel.atlas {
                    RegionAtlasContent(
                        atlas: atlas,
                        onRegionClick: { region in
                            navigateToRegion = region
                        }
                    )
                }
            }
        }
        .navigationTitle("page.regionAtlas")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.loadAtlas()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
        }
        #endif
        .task {
            if viewModel.atlas == nil && viewModel.error == nil {
                viewModel.loadAtlas()
            }
        }
        .navigationDestination(item: $navigateToRegion) { region in
            RegionDetailView(region: region)
        }
    }
}

// MARK: - 地区图谱内容

private struct RegionAtlasContent: View {
    let atlas: RegionAtlasDTO
    let onRegionClick: (String) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // 标题和地区总数
                VStack(alignment: .leading, spacing: 4) {
                    if let regionCount = atlas.totals?.regionCount {
                        Text(String(format: String(localized: "search.resultsCount"), regionCount))
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }
                }

                // 总计信息
                if let totals = atlas.totals {
                    RegionAtlasTotalsBar(totals: totals)
                        .padding(.horizontal, 16)
                }

                // 地区网格
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(Array(atlas.regions.enumerated()), id: \.offset) { _, item in
                        RegionCard(item: item) {
                            if let region = item.region {
                                onRegionClick(region)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)

                // 底部间距
                Spacer()
                    .frame(height: 18)
            }
            .padding(.vertical, 16)
        }
    }
}

// MARK: - 总计信息栏

private struct RegionAtlasTotalsBar: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let totals: RegionAtlasTotalsDTO

    var body: some View {
        HStack(spacing: 12) {
            TotalsChip(
                count: totals.directoryItemCount,
                label: String(localized: "region.totalDirectory")
            )
            TotalsChip(
                count: totals.inheritorCount,
                label: String(localized: "region.totalInheritors")
            )
        }
    }
}

private struct TotalsChip: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(HeritageTypography.titleLarge)
                .fontWeight(.bold)
                .foregroundStyle(colorScheme.onPrimaryContainer)

            Text(label)
                .font(HeritageTypography.labelMedium)
                .foregroundStyle(colorScheme.onPrimaryContainer)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(colorScheme.primaryContainer)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - 地区卡片

private struct RegionCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let item: RegionAtlasItemDTO
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.displayName ?? item.region ?? "")
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(colorScheme.onSurface)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    MetaChip(String(format: String(localized: "region.itemsFormat %lld"), item.directoryItemCount))
                    MetaChip(String(format: String(localized: "region.inheritorsFormat %lld"), item.inheritorCount))
                }

                // Top categories
                if !item.topCategories.isEmpty {
                    let joined = item.topCategories.prefix(2).compactMap(\.key).joined(separator: "、")
                    if !joined.isEmpty {
                        Text(joined)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }

                // Top kinds
                if !item.topKinds.isEmpty {
                    let joined = item.topKinds.prefix(2).compactMap(\.key).joined(separator: "、")
                    if !joined.isEmpty {
                        Text(joined)
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(colorScheme.surfaceContainerHigh)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 错误内容

private struct RegionAtlasErrorContent: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(colorScheme.onSurfaceVariant)

            Text(verbatim: error.localizedDescription)
                .font(HeritageTypography.bodyMedium)
                .foregroundStyle(colorScheme.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button("action.retry") {
                onRetry()
            }
            .font(HeritageTypography.labelLarge)
            .foregroundStyle(colorScheme.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Hashable

extension String: @retroactive Identifiable {
    public var id: String { self }
}

#Preview {
    NavigationStack {
        RegionAtlasView()
    }
    .heritageTheme()
}
