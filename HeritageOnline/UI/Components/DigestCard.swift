import SwiftUI

/// 内容速览卡片
/// 对齐 Android DigestCard
/// 展示 quickRead 摘要、阅读时间、要点、关键信息和关键词
struct DigestCard: View {
    @Environment(\.heritageColorScheme) private var colorScheme

    let digest: ContentDigestDTO

    @State private var expanded = false

    var body: some View {
        ContentCard {
            VStack(alignment: .leading, spacing: 10) {
                // 标题
                Text(String(localized: "digest.title"))
                    .font(HeritageTypography.titleMedium)
                    .fontWeight(.semibold)

                // quickRead 正文
                if let quickRead = digest.quickRead, !quickRead.isEmpty {
                    Text(quickRead)
                        .font(HeritageTypography.bodyMedium)
                        .foregroundStyle(colorScheme.onSurfaceVariant)
                }

                // 阅读时间
                if digest.readingTimeMinutes > 0 {
                    Text(String(format: String(localized: "digest.readingTime %lld"), digest.readingTimeMinutes))
                        .font(HeritageTypography.labelMedium)
                        .foregroundStyle(colorScheme.primary)
                }

                // 要点
                if !digest.highlights.isEmpty {
                    Text(String(localized: "digest.highlights"))
                        .font(HeritageTypography.labelLarge)
                        .fontWeight(.semibold)

                    let displayHighlights = expanded ? digest.highlights : Array(digest.highlights.prefix(3))
                    ForEach(Array(displayHighlights.enumerated()), id: \.offset) { _, highlight in
                        Text("• \(highlight)")
                            .font(HeritageTypography.bodyMedium)
                            .foregroundStyle(colorScheme.onSurfaceVariant)
                    }

                    if digest.highlights.count > 3 {
                        Button(action: { expanded.toggle() }) {
                            Text(String(localized: expanded ? "digest.showLess" : "digest.showMore"))
                                .font(HeritageTypography.labelMedium)
                                .foregroundStyle(colorScheme.primary)
                        }
                    }
                }

                // 关键信息
                if !digest.keyFacts.isEmpty {
                    Text(String(localized: "digest.keyFacts"))
                        .font(HeritageTypography.labelLarge)
                        .fontWeight(.semibold)

                    FlowLayout(spacing: 8) {
                        ForEach(Array(digest.keyFacts.enumerated()), id: \.offset) { _, fact in
                            MetaChip("\(fact.label): \(fact.value)")
                        }
                    }
                }

                // 关键词
                if !digest.keywords.isEmpty {
                    Text(String(localized: "digest.keywords"))
                        .font(HeritageTypography.labelLarge)
                        .fontWeight(.semibold)

                    FlowLayout(spacing: 6) {
                        ForEach(Array(digest.keywords.enumerated()), id: \.offset) { _, keyword in
                            MetaChip(keyword)
                        }
                    }
                }
            }
            .padding(14)
        }
    }
}

#Preview {
    VStack {
        Text("DigestCard Preview")
            .font(HeritageTypography.headlineMedium)
        // Preview requires backend data; use ComponentPreviewView for live preview
    }
    .padding()
    .heritageTheme()
}
