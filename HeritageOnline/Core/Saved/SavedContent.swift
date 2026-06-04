import Foundation

/// 保存内容类型
enum SavedContentType: String, Codable, Sendable {
    case article
    case directoryItem
    case inheritor
}

/// 保存内容模型
/// 同时服务收藏和最近浏览
/// 对齐 Android SavedContentEntity
struct SavedContent: Codable, Identifiable, Sendable {
    /// 唯一标识（由 computeKey 计算）
    let contentKey: String
    var id: String { contentKey }

    /// 内容类型
    let contentType: SavedContentType

    /// 展示字段
    var title: String
    var subtitle: String?
    var summary: String?
    var imageUrl: String?
    let category: String?
    let region: String?

    /// 回跳导航标识
    let targetId: String?
    let targetSourceId: String?
    let targetSourceUrl: String?
    let targetCategory: String?
    let targetKind: String?

    /// 收藏状态
    var isFavorite: Bool
    var favoritedAt: Date?

    /// 浏览状态
    var lastViewedAt: Date?

    /// 计算 key：优先 targetId > sourceUrl > sourceId
    static func computeKey(
        targetId: String?,
        targetSourceUrl: String?,
        targetSourceId: String?
    ) -> String {
        if let id = targetId, !id.isEmpty { return "id:\(id)" }
        if let url = targetSourceUrl, !url.isEmpty { return "url:\(url)" }
        if let sid = targetSourceId, !sid.isEmpty { return "sid:\(sid)" }
        return "unknown:\(UUID().uuidString)"
    }
}

// MARK: - 从 DTO 构造 Snapshot

extension SavedContent {
    /// 从文章详情构造
    static func fromArticle(_ article: ArticleDetailDTO) -> SavedContent {
        let key = computeKey(
            targetId: article.id,
            targetSourceUrl: article.sourceUrl,
            targetSourceId: article.sourceId
        )
        return SavedContent(
            contentKey: key,
            contentType: .article,
            title: article.title ?? "",
            subtitle: article.sourceName,
            summary: article.summary,
            imageUrl: ImagePreviewUrl.listUrl(from: article.coverImage),
            category: article.category,
            region: nil,
            targetId: article.id,
            targetSourceId: article.sourceId,
            targetSourceUrl: article.sourceUrl,
            targetCategory: article.category,
            targetKind: nil,
            isFavorite: false,
            favoritedAt: nil,
            lastViewedAt: nil
        )
    }

    /// 从名录详情构造
    static func fromDirectoryItem(_ item: DirectoryItemDetailDTO) -> SavedContent {
        let key = computeKey(
            targetId: item.id,
            targetSourceUrl: item.sourceUrl,
            targetSourceId: item.sourceId
        )
        return SavedContent(
            contentKey: key,
            contentType: .directoryItem,
            title: item.title ?? "",
            subtitle: item.kind,
            summary: item.summary,
            imageUrl: ImagePreviewUrl.listUrl(from: item.coverImage),
            category: item.category,
            region: item.region,
            targetId: item.id,
            targetSourceId: item.sourceId,
            targetSourceUrl: item.sourceUrl,
            targetCategory: item.category,
            targetKind: item.kind,
            isFavorite: false,
            favoritedAt: nil,
            lastViewedAt: nil
        )
    }

    /// 从传承人详情构造
    static func fromInheritor(_ item: InheritorDetailDTO) -> SavedContent {
        let key = computeKey(
            targetId: item.id,
            targetSourceUrl: item.sourceUrl,
            targetSourceId: item.sourceId
        )
        return SavedContent(
            contentKey: key,
            contentType: .inheritor,
            title: item.name ?? "",
            subtitle: item.projectName,
            summary: item.description,
            imageUrl: ImagePreviewUrl.listUrl(from: item.coverImage),
            category: item.category,
            region: item.region,
            targetId: item.id,
            targetSourceId: item.sourceId,
            targetSourceUrl: item.sourceUrl,
            targetCategory: item.category,
            targetKind: nil,
            isFavorite: false,
            favoritedAt: nil,
            lastViewedAt: nil
        )
    }
}
