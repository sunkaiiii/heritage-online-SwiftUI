import Foundation

/// 图片 URL 选择工具
/// 对齐 Android ImagePreviewUrl.kt 和 ImagePreviewUrls.kt
enum ImagePreviewUrl {
    /// 列表图片 URL 选择
    /// 优先级：displayUrl -> thumbnailUrl -> originalUrl -> sourceUrl
    static func listUrl(from asset: MediaAssetDTO?) -> String? {
        asset?.displayUrl ?? asset?.thumbnailUrl ?? asset?.originalUrl ?? asset?.sourceUrl
    }

    /// 预览图片 URL 选择
    /// 优先级：originalUrl -> displayUrl -> sourceUrl -> thumbnailUrl
    static func previewUrl(from asset: MediaAssetDTO?) -> String? {
        asset?.originalUrl ?? asset?.displayUrl ?? asset?.sourceUrl ?? asset?.thumbnailUrl
    }

    /// 从 MediaAssetDTO 列表中提取预览 URL
    static func previewUrls(from assets: [MediaAssetDTO]) -> [String] {
        assets.compactMap { previewUrl(from: $0) }
    }

    /// 从 MediaAssetDTO 列表中提取列表 URL
    static func listUrls(from assets: [MediaAssetDTO]) -> [String] {
        assets.compactMap { listUrl(from: $0) }
    }

    /// 收集所有可预览的图片 URL
    /// 从封面图、图库、内容块中提取
    /// - Parameters:
    ///   - coverImage: 封面图
    ///   - gallery: 图库
    ///   - contentBlocks: 内容块
    /// - Returns: 去重后的预览 URL 数组（保持顺序）
    static func collect(
        coverImage: MediaAssetDTO?,
        gallery: [MediaAssetDTO],
        contentBlocks: [ArticleContentBlockDTO]
    ) -> [String] {
        var urls: [String] = []

        // 1. 封面图
        if let coverUrl = previewUrl(from: coverImage) {
            urls.append(coverUrl)
        }

        // 2. 图库
        urls.append(contentsOf: previewUrls(from: gallery))

        // 3. 内容块中的图片
        let contentImages = contentBlocks.compactMap { $0.image }
        urls.append(contentsOf: previewUrls(from: contentImages))

        // 稳定去重（保持顺序）
        var seen = Set<String>()
        return urls.filter { seen.insert($0).inserted }
    }
}
