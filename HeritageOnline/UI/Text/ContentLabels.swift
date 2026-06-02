import Foundation

/// 内容标签本地化 key 工具
/// 将后端 wire value 映射为本地化 key；未知值原样返回。
enum ContentLabels {
    // MARK: - Content Types

    static func contentTypeKey(_ type: String?) -> String {
        guard let type else { return "" }
        switch type {
        case "article": return "contentType.article"
        case "directoryItem": return "contentType.directoryItem"
        case "inheritor": return "contentType.inheritor"
        case "collection": return "contentType.collection"
        case "topic": return "contentType.topic"
        default: return type
        }
    }

    // 兼容旧调用点；新 UI 应使用 key 并在 View 层渲染。
    static func localizedContentType(_ type: String?) -> String {
        contentTypeKey(type)
    }

    // MARK: - Article Categories

    static func articleCategoryKey(_ category: String?) -> String? {
        guard let category, !category.isEmpty else { return nil }
        switch category {
        case "news": return "articleCategory.news"
        case "forum": return "articleCategory.forum"
        case "specialTopic": return "articleCategory.specialTopic"
        default: return category
        }
    }

    static func localizedArticleCategory(_ category: String?) -> String? {
        articleCategoryKey(category)
    }

    // MARK: - Directory Kinds

    static func directoryKindKey(_ kind: String?) -> String? {
        guard let kind, !kind.isEmpty else { return nil }
        switch kind {
        case "nationalProject": return "directoryKind.nationalProject"
        case "culturalEcoZone": return "directoryKind.culturalEcoZone"
        case "productiveProtectionBase": return "directoryKind.productiveProtectionBase"
        case "unescoEntry": return "directoryKind.unescoEntry"
        case "chinaUnescoEntry": return "directoryKind.chinaUnescoEntry"
        case "contractingState": return "directoryKind.contractingState"
        default: return kind
        }
    }

    static func localizedDirectoryKind(_ kind: String?) -> String? {
        directoryKindKey(kind)
    }

    // MARK: - Reading Path Sources

    static func readingPathSourceKey(_ source: String) -> String {
        switch source {
        case "blendedRecommendation": return "readingPathSource.blendedRecommendation"
        case "related": return "readingPathSource.related"
        case "recommendation": return "readingPathSource.recommendation"
        case "semanticRecommendation": return "readingPathSource.semanticRecommendation"
        case "graph": return "readingPathSource.graph"
        case "list": return "readingPathSource.list"
        default: return source
        }
    }

    static func localizedReadingPathSource(_ source: String) -> String {
        readingPathSourceKey(source)
    }

    // MARK: - Search Result Types

    static func searchResultTypeKey(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "article": return "contentType.article"
        case "directoryItem": return "contentType.directoryItem"
        case "inheritor": return "contentType.inheritor"
        default: return type
        }
    }

    static func localizedSearchResultType(_ type: String?) -> String? {
        searchResultTypeKey(type)
    }

    // MARK: - Timeline Types

    static func timelineTypeKey(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "article": return "contentType.article"
        case "directoryItem": return "contentType.directoryItem"
        case "inheritor": return "contentType.inheritor"
        default: return type
        }
    }

    static func localizedTimelineType(_ type: String?) -> String? {
        timelineTypeKey(type)
    }

    // MARK: - Discovery Types

    static func discoveryTypeKey(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "today": return "discovery.today"
        case "trending": return "discovery.trending"
        case "weekly": return "discovery.weekly"
        case "serendipity": return "discovery.serendipity"
        case "deepDive": return "discovery.deepDive"
        default: return type
        }
    }

    static func localizedDiscoveryType(_ type: String?) -> String? {
        discoveryTypeKey(type)
    }

    // MARK: - Explore Topic Types

    static func exploreTopicTypeKey(_ type: String?) -> String? {
        guard let type, !type.isEmpty else { return nil }
        switch type {
        case "region": return "stats.regions"
        case "category": return "stats.categories"
        case "year": return "stats.year"
        case "kind": return "stats.kind"
        default: return type
        }
    }

    static func localizedExploreTopicType(_ type: String?) -> String? {
        exploreTopicTypeKey(type)
    }
}
