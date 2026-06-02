import Foundation

/// 内容标签本地化工具
/// 将后端 wire value 映射为本地化显示文案
/// 完全对齐 Android ContentLabels.kt
enum ContentLabels {
    // MARK: - Content Types

    /// 将内容类型 wire value 映射为本地化显示文案
    /// 覆盖 article / directoryItem / inheritor / collection / topic
    /// 未知值原样返回，不崩溃
    static func localizedContentType(_ type: String?) -> String {
        guard let type else { return "" }
        switch type {
        case "article":
            return String(localized: "contentType.article")
        case "directoryItem":
            return String(localized: "contentType.directoryItem")
        case "inheritor":
            return String(localized: "contentType.inheritor")
        case "collection":
            return String(localized: "contentType.collection")
        case "topic":
            return String(localized: "contentType.topic")
        default:
            return type
        }
    }

    // MARK: - Article Categories

    /// 将文章分类 wire value 映射为本地化显示文案
    /// 覆盖 news / forum / specialTopic
    /// 未知值返回原值
    static func localizedArticleCategory(_ category: String?) -> String? {
        guard let category, !category.isEmpty else { return nil }
        switch category {
        case "news":
            return String(localized: "articleCategory.news")
        case "forum":
            return String(localized: "articleCategory.forum")
        case "specialTopic":
            return String(localized: "articleCategory.specialTopic")
        default:
            return category
        }
    }

    // MARK: - Directory Kinds

    /// 将名录种类 wire value 映射为本地化显示文案
    /// 覆盖 nationalProject / culturalEcoZone / productiveProtectionBase / unescoEntry / chinaUnescoEntry / contractingState
    /// 未知值返回原值
    static func localizedDirectoryKind(_ kind: String?) -> String? {
        guard let kind, !kind.isEmpty else { return nil }
        switch kind {
        case "nationalProject":
            return String(localized: "directoryKind.nationalProject")
        case "culturalEcoZone":
            return String(localized: "directoryKind.culturalEcoZone")
        case "productiveProtectionBase":
            return String(localized: "directoryKind.productiveProtectionBase")
        case "unescoEntry":
            return String(localized: "directoryKind.unescoEntry")
        case "chinaUnescoEntry":
            return String(localized: "directoryKind.chinaUnescoEntry")
        case "contractingState":
            return String(localized: "directoryKind.contractingState")
        default:
            return kind
        }
    }

    // MARK: - Reading Path Sources

    /// 将阅读路径来源 wire value 映射为本地化显示文案
    /// 覆盖 blendedRecommendation / related / recommendation / semanticRecommendation / graph / list
    /// 未知值返回原值
    static func localizedReadingPathSource(_ source: String) -> String {
        switch source {
        case "blendedRecommendation":
            return String(localized: "readingPathSource.blendedRecommendation")
        case "related":
            return String(localized: "readingPathSource.related")
        case "recommendation":
            return String(localized: "readingPathSource.recommendation")
        case "semanticRecommendation":
            return String(localized: "readingPathSource.semanticRecommendation")
        case "graph":
            return String(localized: "readingPathSource.graph")
        case "list":
            return String(localized: "readingPathSource.list")
        default:
            return source
        }
    }

    // MARK: - Search Result Types

    /// 将搜索结果类型 wire value 映射为本地化显示文案
    static func localizedSearchResultType(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "article":
            return String(localized: "contentType.article")
        case "directoryItem":
            return String(localized: "contentType.directoryItem")
        case "inheritor":
            return String(localized: "contentType.inheritor")
        default:
            return type
        }
    }

    // MARK: - Timeline Types

    /// 将时间线类型 wire value 映射为本地化显示文案
    static func localizedTimelineType(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "article":
            return String(localized: "contentType.article")
        case "directoryItem":
            return String(localized: "contentType.directoryItem")
        case "inheritor":
            return String(localized: "contentType.inheritor")
        default:
            return type
        }
    }

    // MARK: - Discovery Types

    /// 将发现类型 wire value 映射为本地化显示文案
    static func localizedDiscoveryType(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "today":
            return String(localized: "discovery.today")
        case "trending":
            return String(localized: "discovery.trending")
        case "weekly":
            return String(localized: "discovery.weekly")
        case "serendipity":
            return String(localized: "discovery.serendipity")
        case "deepDive":
            return String(localized: "discovery.deepDive")
        default:
            return type
        }
    }

    // MARK: - Explore Topic Types

    /// 将探索主题类型 wire value 映射为本地化显示文案
    static func localizedExploreTopicType(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "region":
            return String(localized: "stats.regions")
        case "category":
            return String(localized: "stats.categories")
        case "year":
            return String(localized: "stats.year")
        case "kind":
            return String(localized: "stats.kind")
        default:
            return type
        }
    }
}
