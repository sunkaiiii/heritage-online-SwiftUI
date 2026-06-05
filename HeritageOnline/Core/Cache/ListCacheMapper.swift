import Foundation
import CryptoKit

// MARK: - String 安全文件名扩展（使用 SHA256 避免中文碰撞）

extension String {
    /// 使用 SHA256 哈希生成安全文件名
    /// 避免中文字符和非 ASCII 字符碰撞问题
    var sha256Hash: String {
        let data = Data(utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - QueryKey 计算

/// 文章查询的 queryKey
/// 对齐 Android ArticleQuery.queryKey()
extension ArticleQuery {
    var queryKey: String {
        [category.rawValue, year?.description ?? "", keywords ?? ""]
            .joined(separator: "|")
    }
}

/// 名录查询的 queryKey
/// 对齐 Android DirectoryItemQuery.queryKey()
extension DirectoryItemQuery {
    var queryKey: String {
        [
            kind.rawValue,
            region ?? "",
            category ?? "",
            year?.description ?? "",
            keywords ?? "",
            listType ?? "",
        ].joined(separator: "|")
    }
}

/// 传承人查询的 queryKey
/// 对齐 Android InheritorQuery.queryKey()
extension InheritorQuery {
    var queryKey: String {
        [
            region ?? "",
            category ?? "",
            year?.description ?? "",
            gender ?? "",
            keywords ?? "",
        ].joined(separator: "|")
    }
}

// MARK: - ArticleSummaryDTO <-> ArticleListCacheEntity

extension ArticleSummaryDTO {
    func toListEntity(query: ArticleQuery, page: Int, positionInPage: Int) -> ArticleListCacheEntity {
        ArticleListCacheEntity(
            id: id ?? sourceUrl ?? "\(query.queryKey)-\(page)-\(positionInPage)",
            queryKey: query.queryKey,
            category: category ?? "",
            title: title,
            summary: summary,
            publishedAt: publishedAt,
            coverImageJson: coverImage.flatMap { try? JSONEncoder().encode($0) }.flatMap { String(data: $0, encoding: .utf8) },
            sourceUrl: sourceUrl,
            page: page,
            positionInPage: positionInPage
        )
    }
}

extension ArticleListCacheEntity {
    func toDTO() -> ArticleSummaryDTO {
        ArticleSummaryDTO(
            id: id,
            category: category,
            title: title,
            summary: summary,
            publishedAt: publishedAt,
            coverImage: coverImageJson.flatMap { $0.data(using: .utf8) }.flatMap { try? JSONDecoder().decode(MediaAssetDTO.self, from: $0) },
            sourceUrl: sourceUrl
        )
    }
}

// MARK: - DirectoryItemSummaryDTO <-> DirectoryListCacheEntity

extension DirectoryItemSummaryDTO {
    func toListEntity(query: DirectoryItemQuery, page: Int, positionInPage: Int) -> DirectoryListCacheEntity {
        DirectoryListCacheEntity(
            id: id ?? sourceUrl ?? "\(query.queryKey)-\(page)-\(positionInPage)",
            queryKey: query.queryKey,
            kind: kind ?? "",
            title: title,
            summary: summary,
            category: category,
            region: region,
            projectCode: projectCode,
            batch: batch,
            publishedYear: publishedYear,
            listType: listType,
            coverImageJson: coverImage.flatMap { try? JSONEncoder().encode($0) }.flatMap { String(data: $0, encoding: .utf8) },
            sourceUrl: sourceUrl,
            page: page,
            positionInPage: positionInPage
        )
    }
}

extension DirectoryListCacheEntity {
    func toDTO() -> DirectoryItemSummaryDTO {
        DirectoryItemSummaryDTO(
            id: id,
            kind: kind,
            title: title,
            summary: summary,
            category: category,
            region: region,
            projectCode: projectCode,
            batch: batch,
            publishedYear: publishedYear,
            listType: listType,
            coverImage: coverImageJson.flatMap { $0.data(using: .utf8) }.flatMap { try? JSONDecoder().decode(MediaAssetDTO.self, from: $0) },
            sourceUrl: sourceUrl
        )
    }
}

// MARK: - InheritorSummaryDTO <-> InheritorListCacheEntity

extension InheritorSummaryDTO {
    func toListEntity(query: InheritorQuery, page: Int, positionInPage: Int) -> InheritorListCacheEntity {
        InheritorListCacheEntity(
            id: id ?? sourceUrl ?? "\(query.queryKey)-\(page)-\(positionInPage)",
            queryKey: query.queryKey,
            name: name,
            gender: gender,
            birthDateText: birthDateText,
            ethnicity: ethnicity,
            category: category,
            projectName: projectName,
            projectCode: projectCode,
            region: region,
            batch: batch,
            description: description,
            coverImageJson: coverImage.flatMap { try? JSONEncoder().encode($0) }.flatMap { String(data: $0, encoding: .utf8) },
            sourceUrl: sourceUrl,
            page: page,
            positionInPage: positionInPage
        )
    }
}

extension InheritorListCacheEntity {
    func toDTO() -> InheritorSummaryDTO {
        InheritorSummaryDTO(
            id: id,
            name: name,
            gender: gender,
            birthDateText: birthDateText,
            ethnicity: ethnicity,
            category: category,
            projectCode: projectCode,
            projectName: projectName,
            region: region,
            batch: batch,
            description: description,
            coverImage: coverImageJson.flatMap { $0.data(using: .utf8) }.flatMap { try? JSONDecoder().decode(MediaAssetDTO.self, from: $0) },
            sourceUrl: sourceUrl
        )
    }
}
