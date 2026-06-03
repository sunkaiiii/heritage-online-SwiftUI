import Foundation

/// 阅读路径来源枚举
/// 对齐 Android DetailExploreSource
enum ReadingPathSource: String, Codable, Sendable {
    case blendedRecommendation
    case related
    case recommendation
    case semanticRecommendation
    case graph
    case list

    /// 本地化显示名称
    var displayName: String {
        let key = "readingPathSource.\(rawValue)"
        return String(localized: String.LocalizationValue(key))
    }
}

/// 阅读路径事件
/// 对齐 Android ReadingPathEvent
struct ReadingPathEvent: Codable, Identifiable, Sendable {
    /// 稳定 ID：{fromType}:{fromId}->{toType}:{toId}:{source}
    let id: String

    /// 来源内容
    let fromType: SavedContentType
    let fromId: String
    let fromTitle: String

    /// 目标内容
    let toType: SavedContentType
    let toId: String
    let toTitle: String

    /// 跳转来源
    let source: ReadingPathSource

    /// 目标导航信息
    let toCategory: String?
    let toKind: String?
    let toSourceId: String?
    let toSourceUrl: String?
    let toSubtitle: String?
    let toImageUrl: String?

    /// 记录时间
    var createdAt: Date

    /// 生成稳定 ID
    static func computeId(
        fromType: SavedContentType,
        fromId: String,
        toType: SavedContentType,
        toId: String,
        source: ReadingPathSource
    ) -> String {
        "\(fromType.rawValue):\(fromId)->\(toType.rawValue):\(toId):\(source.rawValue)"
    }
}

// MARK: - 从详情页构造

extension ReadingPathEvent {
    /// 从当前文章详情构造 from 引用
    static func fromRef(_ article: ArticleDetailDTO) -> (type: SavedContentType, id: String, title: String) {
        (.article, article.id ?? "", article.title ?? "")
    }

    /// 从当前名录详情构造 from 引用
    static func fromRef(_ item: DirectoryItemDetailDTO) -> (type: SavedContentType, id: String, title: String) {
        (.directoryItem, item.id ?? "", item.title ?? "")
    }

    /// 从当前传承人详情构造 from 引用
    static func fromRef(_ item: InheritorDetailDTO) -> (type: SavedContentType, id: String, title: String) {
        (.inheritor, item.id ?? "", item.name ?? "")
    }
}
