import SwiftUI

/// 详情页内容块视图
/// 统一处理 heading/text/image 类型的内容块渲染和图片预览
struct DetailContentBlockView: View {
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
                if Self.isStandaloneSectionTitle(text) {
                    Text(text)
                        .font(HeritageTypography.titleMedium)
                        .fontWeight(.semibold)
                        .foregroundStyle(colorScheme.onSurface)
                } else {
                    Text(text)
                        .font(HeritageTypography.bodyLarge)
                        .foregroundStyle(colorScheme.onSurface)
                        .lineSpacing(6)
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
                        if let imageIndex {
                            onPreviewImage(previewURLs, imageIndex)
                        } else if let urlString, let idx = previewURLs.firstIndex(of: urlString) {
                            onPreviewImage(previewURLs, idx)
                        }
                    }
                )
                .aspectRatio(4/3, contentMode: .fit)
            }
        }
    }

    /// 判断是否为独立短标题（对齐 Android isStandaloneSectionTitle）
    static func isStandaloneSectionTitle(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        if trimmed.hasSuffix("：") || trimmed.hasSuffix(":") {
            return trimmed.count <= 32
        }
        let sentenceEnders: [Character] = ["。", "！", "？", ".", "!", "?", "；", ";"]
        let hasSentenceEnder = trimmed.contains(where: { sentenceEnders.contains($0) })
        return !hasSentenceEnder && trimmed.count <= 18
    }
}
