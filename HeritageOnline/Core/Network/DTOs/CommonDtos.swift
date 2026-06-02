import Foundation

/// 媒体资源 DTO
/// 完全对齐 Android MediaAssetDto
struct MediaAssetDTO: Codable, Sendable {
    let sourceUrl: String?
    let originalUrl: String?
    let displayUrl: String?
    let thumbnailUrl: String?
    let altText: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
        originalUrl = try container.decodeIfPresent(String.self, forKey: .originalUrl)
        displayUrl = try container.decodeIfPresent(String.self, forKey: .displayUrl)
        thumbnailUrl = try container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        altText = try container.decodeIfPresent(String.self, forKey: .altText)
    }
}

/// 错误详情 DTO
/// 完全对齐 Android ProblemDetailsDto
struct ProblemDetailsDTO: Codable, Sendable {
    let type: String?
    let title: String?
    let status: Int?
    let detail: String?
    let instance: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
        instance = try container.decodeIfPresent(String.self, forKey: .instance)
    }
}

/// Facet Bucket DTO
/// 完全对齐 Android FacetBucketDto
struct FacetBucketDTO: Codable, Sendable {
    let key: String?
    let count: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        count = try container.decodeIfPresent(Int.self, forKey: .count) ?? 0
    }
}

/// 探索主题链接 DTO
/// 完全对齐 Android ExploreTopicLinkDto
struct ExploreTopicLinkDTO: Codable, Sendable {
    let type: String?
    let key: String?
    let title: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}
