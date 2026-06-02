import Foundation

/// 图片 URL 选择工具
/// 完全对齐 Android ImagePreviewUrl.kt
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
}
