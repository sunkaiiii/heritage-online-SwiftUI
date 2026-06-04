import Foundation

// MARK: - 列表缓存 Entity

/// 文章列表缓存实体
/// 对齐 Android ArticleEntity
struct ArticleListCacheEntity: Codable, Sendable {
    let id: String
    let queryKey: String
    let category: String
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImageJson: String?
    let sourceUrl: String?
    let page: Int
    let positionInPage: Int
}

/// 名录列表缓存实体
/// 对齐 Android DirectoryItemEntity
struct DirectoryListCacheEntity: Codable, Sendable {
    let id: String
    let queryKey: String
    let kind: String
    let title: String?
    let summary: String?
    let category: String?
    let region: String?
    let projectCode: String?
    let batch: String?
    let publishedYear: Int?
    let listType: String?
    let coverImageJson: String?
    let sourceUrl: String?
    let page: Int
    let positionInPage: Int
}

/// 传承人列表缓存实体
/// 对齐 Android InheritorEntity
struct InheritorListCacheEntity: Codable, Sendable {
    let id: String
    let queryKey: String
    let name: String?
    let gender: String?
    let ethnicity: String?
    let category: String?
    let projectName: String?
    let projectCode: String?
    let region: String?
    let batch: String?
    let description: String?
    let coverImageJson: String?
    let sourceUrl: String?
    let page: Int
    let positionInPage: Int
}

// MARK: - Remote Key Entity

/// 文章远程分页 Key
/// 对齐 Android ArticleRemoteKeyEntity
struct ArticleRemoteKeyEntity: Codable, Sendable {
    let queryKey: String
    let nextPage: Int?
    let hasMore: Bool
}

/// 名录远程分页 Key
struct DirectoryRemoteKeyEntity: Codable, Sendable {
    let queryKey: String
    let nextPage: Int?
    let hasMore: Bool
}

/// 传承人远程分页 Key
struct InheritorRemoteKeyEntity: Codable, Sendable {
    let queryKey: String
    let nextPage: Int?
    let hasMore: Bool
}
