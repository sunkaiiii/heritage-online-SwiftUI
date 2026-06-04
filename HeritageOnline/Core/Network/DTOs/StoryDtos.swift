import Foundation

// MARK: - 数据故事 DTO

struct DataStoryDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let subtitle: String?
    let heroImage: MediaAssetDTO?
    let sections: [DataStorySectionDTO]
    let relatedTopics: [ExploreTopicRefDTO]
    let generatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, heroImage, sections, relatedTopics, generatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        heroImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .heroImage)
        sections = try container.decodeIfPresent([DataStorySectionDTO].self, forKey: .sections) ?? []
        relatedTopics = try container.decodeIfPresent([ExploreTopicRefDTO].self, forKey: .relatedTopics) ?? []
        generatedAt = try container.decodeIfPresent(String.self, forKey: .generatedAt)
    }
}

struct DataStorySectionDTO: Decodable, Sendable {
    let id: String?
    let title: String?
    let type: String?
    let body: String?
    let items: [DataStoryItemDTO]

    enum CodingKeys: String, CodingKey {
        case id, title, type, body, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        items = try container.decodeIfPresent([DataStoryItemDTO].self, forKey: .items) ?? []
    }
}

struct DataStoryItemDTO: Decodable, Sendable {
    let type: String?
    let id: String?
    let title: String?
    let summary: String?
    let coverImage: MediaAssetDTO?
    let sourceUrl: String?

    enum CodingKeys: String, CodingKey {
        case type, id, title, summary, coverImage, sourceUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        coverImage = try container.decodeIfPresent(MediaAssetDTO.self, forKey: .coverImage)
        sourceUrl = try container.decodeIfPresent(String.self, forKey: .sourceUrl)
    }
}

