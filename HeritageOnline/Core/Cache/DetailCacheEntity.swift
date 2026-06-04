import Foundation

// MARK: - 文章详情缓存实体

/// 文章详情本地缓存实体
/// 对齐 Android ArticleDetailEntity
struct ArticleDetailCacheEntity: Codable, Sendable {
    let id: String
    let sourceId: String?
    let category: String
    let title: String?
    let summary: String?
    let publishedAt: String?
    let coverImageJson: String?
    let sourceUrl: String?
    let sourceName: String?
    let author: String?
    let editor: String?
    let contentBlocksJson: String
    let relatedArticlesJson: String
    let updatedAtEpochMillis: Int64
}

// MARK: - 名录详情缓存实体

/// 名录详情本地缓存实体
/// 对齐 Android DirectoryDetailEntity
struct DirectoryDetailCacheEntity: Codable, Sendable {
    let id: String
    let sourceId: String?
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
    let nominationType: String?
    let protectionUnit: String?
    let galleryJson: String
    let contentBlocksJson: String
    let relatedProjectsJson: String
    let relatedInheritorsJson: String
    let relatedDocumentsJson: String
    let updatedAtEpochMillis: Int64
}

// MARK: - 传承人详情缓存实体

/// 传承人详情本地缓存实体
/// 对齐 Android InheritorDetailEntity
struct InheritorDetailCacheEntity: Codable, Sendable {
    let id: String
    let sourceId: String?
    let name: String?
    let gender: String?
    let birthDateText: String?
    let ethnicity: String?
    let category: String?
    let projectCode: String?
    let projectName: String?
    let region: String?
    let batch: String?
    let description: String?
    let coverImageJson: String?
    let sourceUrl: String?
    let contentBlocksJson: String
    let relatedProjectsJson: String
    let relatedInheritorsJson: String
    let updatedAtEpochMillis: Int64
}
