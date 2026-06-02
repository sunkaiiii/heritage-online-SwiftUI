import SwiftUI

/// 名录统计内容视图
/// 对齐 Android DirectoryStatisticsContent
/// 包含：总览 + 年份分布 + 类别分布 + 地区排行
struct DirectoryStatisticsContentView: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let state: DirectoryStatisticsState
    let selectedKind: DirectoryItemKind
    let onRetry: () -> Void

    var body: some View {
        if state.isLoading {
            LoadingPlaceholder()
                .frame(minHeight: 300)
        } else if let error = state.error {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                Text(LocalizedStringKey(error.localizedDescription))
                    .font(HeritageTypography.bodyMedium)
                    .foregroundStyle(colorScheme.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                Button("action.retry") { onRetry() }
                    .font(HeritageTypography.labelLarge)
                    .foregroundStyle(colorScheme.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
        } else if let overview = state.overview {
            VStack(alignment: .leading, spacing: 18) {
                // 总览卡
                overviewCard(overview)

                // 年份分布
                if let yearBD = state.yearBreakdown, !yearBD.items.isEmpty {
                    SectionHeader(title: String(localized: "directory.statistics.yearDistribution"))
                    yearBarChart(yearBD.items)
                }

                // 类别分布
                if let catBD = state.categoryBreakdown, !catBD.items.isEmpty {
                    SectionHeader(title: String(localized: "directory.statistics.categoryDistribution"))
                    categoryCardGrid(catBD.items)
                }

                // 地区排行
                if let regionBD = state.regionBreakdown, !regionBD.items.isEmpty {
                    SectionHeader(title: String(localized: "directory.statistics.regionRanking"))
                    regionRankingList(regionBD.items)
                }
            }
        }
    }

    // MARK: - 总览卡

    private func overviewCard(_ overview: DirectoryStatisticsOverviewDTO) -> some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("\(overview.total)")
                    .font(HeritageTypography.displaySmall)
                    .foregroundStyle(colorScheme.primary)

                Text(selectedKind.displayName)
                    .font(HeritageTypography.titleMedium)
                    .foregroundStyle(colorScheme.onSurface)

                HStack(spacing: 8) {
                    if let generatedAt = overview.generatedAt {
                        Text("\(String(localized: "directory.statistics.generatedAt")): \(formatDate(generatedAt))")
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }
                    Spacer()
                    Text("\(overview.dimensions.count) \(String(localized: "stats.kind"))")
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }
            }
            .padding(16)
        }
    }

    // MARK: - 年份柱状图

    private func yearBarChart(_ items: [DirectoryStatisticItemDTO]) -> some View {
        let maxVal = items.map(\.value).max() ?? 1
        let barColors: [Color] = [colorScheme.primary, colorScheme.tertiary, colorScheme.secondary]

        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let isMax = item.value == maxVal
                    let color = isMax ? colorScheme.primary : barColors[index % barColors.count]
                    let barHeight = maxVal > 0 ? CGFloat(item.value) / CGFloat(maxVal) * 180 : 0

                    VStack(spacing: 4) {
                        Text("\(item.value)")
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: 40, height: max(barHeight, 4))

                        Text(item.key ?? "")
                            .font(HeritageTypography.labelMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - 类别卡片网格

    private func categoryCardGrid(_ items: [DirectoryStatisticItemDTO]) -> some View {
        let total = items.reduce(0) { $0 + $1.value }
        let cardColors: [Color] = [
            colorScheme.primaryContainer,
            colorScheme.tertiaryContainer,
            colorScheme.secondaryContainer,
            colorScheme.surfaceContainerHigh
        ]

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 8)], spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let bgColor = cardColors[index % cardColors.count]
                let pct = total > 0 ? Double(item.value) / Double(total) * 100 : 0

                ContentCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name ?? item.key ?? "")
                            .font(HeritageTypography.titleMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(2)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(item.value)")
                                .font(HeritageTypography.headlineSmall)
                                .foregroundStyle(colorScheme.primary)
                            Text(String(format: "%.1f%%", pct))
                                .font(HeritageTypography.labelMedium)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                        }

                        // 进度条
                        GeometryReader { geo in
                            let barWidth = total > 0 ? geo.size.width * CGFloat(item.value) / CGFloat(total) : 0
                            RoundedRectangle(cornerRadius: 3)
                                .fill(colorScheme.primary.opacity(0.3))
                                .frame(height: 6)
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(colorScheme.primary)
                                        .frame(width: barWidth, height: 6)
                                }
                        }
                        .frame(height: 6)
                    }
                    .padding(12)
                    .background(bgColor)
                    .clipShape(RoundedRectangle(cornerRadius: HeritageShapes.cornerRadius))
                }
            }
        }
    }

    // MARK: - 地区排行

    private func regionRankingList(_ items: [DirectoryStatisticItemDTO]) -> some View {
        let maxVal = items.map(\.value).max() ?? 1
        let rankColors: [Color] = [
            Color(hex: "D4AF37"), // 金
            Color(hex: "C0C0C0"), // 银
            Color(hex: "CD7F32"), // 铜
        ]

        return ContentCard {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    let progress = maxVal > 0 ? CGFloat(item.value) / CGFloat(maxVal) : 0

                    HStack(spacing: 12) {
                        // 排名
                        if index < 3 {
                            Text("\(index + 1)")
                                .font(HeritageTypography.labelLarge)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .background(rankColors[index])
                                .clipShape(Circle())
                        } else {
                            Text("\(index + 1)")
                                .font(HeritageTypography.labelMedium)
                                .foregroundStyle(colorScheme.onSurfaceVariant)
                                .frame(width: 24)
                        }

                        Text(item.name ?? item.key ?? "")
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurface)
                            .lineLimit(1)

                        Spacer()

                        Text("\(item.value)")
                            .font(HeritageTypography.labelLarge)
                            .foregroundStyle(colorScheme.primary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)

                    // 进度条
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(colorScheme.surfaceContainerHighest)
                            .frame(height: 4)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(index < 3 ? colorScheme.primary : colorScheme.surfaceContainerHighest)
                                    .frame(width: geo.size.width * progress, height: 4)
                            }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 6)

                    if index < items.count - 1 {
                        Divider()
                            .background(colorScheme.outlineVariant)
                            .padding(.horizontal, 14)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - 日期格式化

    private func formatDate(_ value: String) -> String {
        if let date = ISO8601DateFormatter().date(from: value) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            formatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
            return formatter.string(from: date)
        }
        if value.count >= 16 {
            return String(value.prefix(16))
        }
        return value
    }
}
