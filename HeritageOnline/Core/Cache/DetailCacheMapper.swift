import Foundation

// MARK: - JSON 编码辅助

/// 安全 JSON 编码，失败返回空 JSON
private func safeEncode<T: Encodable>(_ value: T) -> String {
    (try? JSONEncoder().encode(value))
        .flatMap { String(data: $0, encoding: .utf8) }
        ?? "[]"
}

/// 安全 JSON 解码
private func safeDecode<T: Decodable>(_ json: String?) -> T? {
    guard let json, let data = json.data(using: .utf8) else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
}

// MARK: - ArticleDetailDTO <-> ArticleDetailCacheEntity

extension ArticleDetailDTO {
    /// 从 DTO 转换为缓存实体
    /// 优先使用 DTO 自带的 sourceId/sourceUrl，再 fallback 到 lookup 参数
    func toCacheEntity(
        category: String,
        sourceId: String?,
        sourceUrl: String?
    ) -> ArticleDetailCacheEntity {
        let resolvedSourceId = self.sourceId ?? sourceId
        let resolvedSourceUrl = self.sourceUrl ?? sourceUrl
        return ArticleDetailCacheEntity(
            id: id ?? resolvedSourceId ?? resolvedSourceUrl ?? UUID().uuidString,
            sourceId: resolvedSourceId,
            category: category,
            title: title,
            summary: summary,
            publishedAt: publishedAt,
            coverImageJson: coverImage.flatMap { try? JSONEncoder().encode($0) }.flatMap { String(data: $0, encoding: .utf8) },
            sourceUrl: resolvedSourceUrl,
            sourceName: sourceName,
            author: author,
            editor: editor,
            contentBlocksJson: safeEncode(contentBlocks),
            relatedArticlesJson: safeEncode(relatedArticles),
            updatedAtEpochMillis: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
}

extension ArticleDetailCacheEntity {
    /// 从缓存实体转换为 DTO
    func toDTO() -> ArticleDetailDTO {
        ArticleDetailDTO(
            id: id,
            sourceId: sourceId,
            category: category,
            title: title,
            summary: summary,
            publishedAt: publishedAt,
            coverImage: coverImageJson.flatMap { $0.data(using: .utf8) }.flatMap { try? JSONDecoder().decode(MediaAssetDTO.self, from: $0) },
            sourceUrl: sourceUrl,
            sourceName: sourceName,
            author: author,
            editor: editor,
            contentBlocks: (try? JSONDecoder().decode([ArticleContentBlockDTO].self, from: contentBlocksJson.data(using: .utf8) ?? Data())) ?? [],
            relatedArticles: (try? JSONDecoder().decode([ArticleReferenceDTO].self, from: relatedArticlesJson.data(using: .utf8) ?? Data())) ?? []
        )
    }
}

// MARK: - DirectoryItemDetailDTO <-> DirectoryDetailCacheEntity

extension DirectoryItemDetailDTO {
    /// 从 DTO 转换为缓存实体
    /// 优先使用 DTO 自带的 sourceId，再 fallback 到 lookup 参数
    func toCacheEntity(
        kind: String,
        sourceId: String?
    ) -> DirectoryDetailCacheEntity {
        let resolvedSourceId = self.sourceId ?? sourceId
        return DirectoryDetailCacheEntity(
            id: id ?? resolvedSourceId ?? sourceUrl ?? UUID().uuidString,
            sourceId: resolvedSourceId,
            kind: kind,
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
            nominationType: nominationType,
            protectionUnit: protectionUnit,
            galleryJson: safeEncode(gallery),
            contentBlocksJson: safeEncode(contentBlocks),
            relatedProjectsJson: safeEncode(relatedProjects),
            relatedInheritorsJson: safeEncode(relatedInheritors),
            relatedDocumentsJson: safeEncode(relatedDocuments),
            updatedAtEpochMillis: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
}

extension DirectoryDetailCacheEntity {
    /// 从缓存实体转换为 DTO
    func toDTO() -> DirectoryItemDetailDTO {
        DirectoryItemDetailDTO(
            id: id,
            sourceId: sourceId,
            kind: kind,
            title: title,
            summary: summary,
            category: category,
            region: region,
            projectCode: projectCode,
            batch: batch,
            publishedYear: publishedYear,
            listType: listType,
            nominationType: nominationType,
            protectionUnit: protectionUnit,
            coverImage: coverImageJson.flatMap { $0.data(using: .utf8) }.flatMap { try? JSONDecoder().decode(MediaAssetDTO.self, from: $0) },
            sourceUrl: sourceUrl,
            gallery: (try? JSONDecoder().decode([MediaAssetDTO].self, from: galleryJson.data(using: .utf8) ?? Data())) ?? [],
            contentBlocks: (try? JSONDecoder().decode([ArticleContentBlockDTO].self, from: contentBlocksJson.data(using: .utf8) ?? Data())) ?? [],
            relatedProjects: (try? JSONDecoder().decode([DirectoryReferenceDTO].self, from: relatedProjectsJson.data(using: .utf8) ?? Data())) ?? [],
            relatedInheritors: (try? JSONDecoder().decode([DirectoryReferenceDTO].self, from: relatedInheritorsJson.data(using: .utf8) ?? Data())) ?? [],
            relatedDocuments: (try? JSONDecoder().decode([DirectoryReferenceDTO].self, from: relatedDocumentsJson.data(using: .utf8) ?? Data())) ?? []
        )
    }
}

// MARK: - InheritorDetailDTO <-> InheritorDetailCacheEntity

extension InheritorDetailDTO {
    /// 从 DTO 转换为缓存实体
    /// 优先使用 DTO 自带的 sourceId，再 fallback 到 lookup 参数
    func toCacheEntity(
        sourceId: String?
    ) -> InheritorDetailCacheEntity {
        let resolvedSourceId = self.sourceId ?? sourceId
        return InheritorDetailCacheEntity(
            id: id ?? resolvedSourceId ?? sourceUrl ?? UUID().uuidString,
            sourceId: resolvedSourceId,
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
            coverImageJson: coverImage.flatMap { try? JSONEncoder().encode($0) }.flatMap { String(data: $0, encoding: .utf8) },
            sourceUrl: sourceUrl,
            contentBlocksJson: safeEncode(contentBlocks),
            relatedProjectsJson: safeEncode(relatedProjects),
            relatedInheritorsJson: safeEncode(relatedInheritors),
            updatedAtEpochMillis: Int64(Date().timeIntervalSince1970 * 1000)
        )
    }
}

extension InheritorDetailCacheEntity {
    /// 从缓存实体转换为 DTO
    func toDTO() -> InheritorDetailDTO {
        InheritorDetailDTO(
            id: id,
            sourceId: sourceId,
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
            sourceUrl: sourceUrl,
            contentBlocks: (try? JSONDecoder().decode([ArticleContentBlockDTO].self, from: contentBlocksJson.data(using: .utf8) ?? Data())) ?? [],
            relatedProjects: (try? JSONDecoder().decode([DirectoryReferenceDTO].self, from: relatedProjectsJson.data(using: .utf8) ?? Data())) ?? [],
            relatedInheritors: (try? JSONDecoder().decode([DirectoryReferenceDTO].self, from: relatedInheritorsJson.data(using: .utf8) ?? Data())) ?? []
        )
    }
}
