import Foundation

/// 详情缓存 Repository 接口
/// 对齐 Android Room DAO 的缓存读写能力
protocol DetailCacheRepository: Sendable {
    // MARK: - 文章详情缓存

    /// 通过 id 获取缓存的文章详情
    func cachedArticle(id: String) async -> ArticleDetailDTO?

    /// 通过 sourceId + category 获取缓存的文章详情
    func cachedArticleBySourceId(sourceId: String, category: String) async -> ArticleDetailDTO?

    /// 通过 sourceUrl + category 获取缓存的文章详情
    func cachedArticleBySourceUrl(sourceUrl: String, category: String) async -> ArticleDetailDTO?

    /// 写入文章详情缓存
    func cacheArticle(_ dto: ArticleDetailDTO, lookup: ArticleDetailLookup) async

    // MARK: - 名录详情缓存

    /// 通过 id 获取缓存的名录详情
    func cachedDirectoryItem(id: String) async -> DirectoryItemDetailDTO?

    /// 通过 sourceId + kind 获取缓存的名录详情
    func cachedDirectoryItemBySourceId(sourceId: String, kind: String) async -> DirectoryItemDetailDTO?

    /// 写入名录详情缓存
    func cacheDirectoryItem(_ dto: DirectoryItemDetailDTO, lookup: DirectoryDetailLookup) async

    // MARK: - 传承人详情缓存

    /// 通过 id 获取缓存的传承人详情
    func cachedInheritor(id: String) async -> InheritorDetailDTO?

    /// 通过 sourceId 获取缓存的传承人详情
    func cachedInheritorBySourceId(sourceId: String) async -> InheritorDetailDTO?

    /// 写入传承人详情缓存
    func cacheInheritor(_ dto: InheritorDetailDTO, lookup: InheritorDetailLookup) async

    // MARK: - 清理

    /// 清除所有详情缓存
    func clearAll() async
}

/// 详情缓存 Repository 默认实现
/// 使用基于文件系统的 JSON 缓存
/// @MainActor 确保读写串行化
@MainActor
final class DefaultDetailCacheRepository: DetailCacheRepository {
    static let shared = DefaultDetailCacheRepository()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()

    private let cacheDir: URL

    private init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDir = base.appendingPathComponent("DetailCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    // MARK: - 文章详情缓存

    func cachedArticle(id: String) async -> ArticleDetailDTO? {
        let url = articleCacheURL(id: id)
        guard let entity: ArticleDetailCacheEntity = load(from: url) else { return nil }
        return entity.toDTO()
    }

    func cachedArticleBySourceId(sourceId: String, category: String) async -> ArticleDetailDTO? {
        let url = articleIndexURL(sourceId: sourceId, category: category)
        guard let index: CacheIndex = load(from: url) else { return nil }
        return await cachedArticle(id: index.id)
    }

    func cachedArticleBySourceUrl(sourceUrl: String, category: String) async -> ArticleDetailDTO? {
        let url = articleIndexURL(sourceUrl: sourceUrl, category: category)
        guard let index: CacheIndex = load(from: url) else { return nil }
        return await cachedArticle(id: index.id)
    }

    func cacheArticle(_ dto: ArticleDetailDTO, lookup: ArticleDetailLookup) async {
        let entity = dto.toCacheEntity(
            category: lookup.category.rawValue,
            sourceId: lookup.sourceId,
            sourceUrl: lookup.sourceUrl
        )

        // 写入主缓存
        save(entity, to: articleCacheURL(id: entity.id))

        // 写入索引（使用 entity 最终解析后的字段，确保 DTO 自带的 sourceId/sourceUrl 也被索引）
        let index = CacheIndex(id: entity.id)
        if let sourceId = entity.sourceId, !sourceId.isEmpty {
            save(index, to: articleIndexURL(sourceId: sourceId, category: entity.category))
        }
        if let sourceUrl = entity.sourceUrl, !sourceUrl.isEmpty {
            save(index, to: articleIndexURL(sourceUrl: sourceUrl, category: entity.category))
        }
    }

    // MARK: - 名录详情缓存

    func cachedDirectoryItem(id: String) async -> DirectoryItemDetailDTO? {
        let url = directoryCacheURL(id: id)
        guard let entity: DirectoryDetailCacheEntity = load(from: url) else { return nil }
        return entity.toDTO()
    }

    func cachedDirectoryItemBySourceId(sourceId: String, kind: String) async -> DirectoryItemDetailDTO? {
        let url = directoryIndexURL(sourceId: sourceId, kind: kind)
        guard let index: CacheIndex = load(from: url) else { return nil }
        return await cachedDirectoryItem(id: index.id)
    }

    func cacheDirectoryItem(_ dto: DirectoryItemDetailDTO, lookup: DirectoryDetailLookup) async {
        let entity = dto.toCacheEntity(
            kind: lookup.kind.rawValue,
            sourceId: lookup.sourceId
        )

        // 写入主缓存
        save(entity, to: directoryCacheURL(id: entity.id))

        // 写入索引（使用 entity 最终解析后的字段）
        let index = CacheIndex(id: entity.id)
        if let sourceId = entity.sourceId, !sourceId.isEmpty {
            save(index, to: directoryIndexURL(sourceId: sourceId, kind: entity.kind))
        }
    }

    // MARK: - 传承人详情缓存

    func cachedInheritor(id: String) async -> InheritorDetailDTO? {
        let url = inheritorCacheURL(id: id)
        guard let entity: InheritorDetailCacheEntity = load(from: url) else { return nil }
        return entity.toDTO()
    }

    func cachedInheritorBySourceId(sourceId: String) async -> InheritorDetailDTO? {
        let url = inheritorIndexURL(sourceId: sourceId)
        guard let index: CacheIndex = load(from: url) else { return nil }
        return await cachedInheritor(id: index.id)
    }

    func cacheInheritor(_ dto: InheritorDetailDTO, lookup: InheritorDetailLookup) async {
        let entity = dto.toCacheEntity(sourceId: lookup.sourceId)

        // 写入主缓存
        save(entity, to: inheritorCacheURL(id: entity.id))

        // 写入索引（使用 entity 最终解析后的字段）
        let index = CacheIndex(id: entity.id)
        if let sourceId = entity.sourceId, !sourceId.isEmpty {
            save(index, to: inheritorIndexURL(sourceId: sourceId))
        }
    }

    // MARK: - 清理

    func clearAll() async {
        try? FileManager.default.removeItem(at: cacheDir)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    // MARK: - 内部方法

    /// 缓存索引，用于通过 sourceId/sourceUrl 查找主缓存
    private struct CacheIndex: Codable {
        let id: String
    }

    // 文章缓存路径
    private func articleCacheURL(id: String) -> URL {
        cacheDir.appendingPathComponent("articles").appendingPathComponent("\(id.sha256Hash).json")
    }

    private func articleIndexURL(sourceId: String? = nil, sourceUrl: String? = nil, category: String) -> URL {
        let key: String
        if let sourceId {
            key = "sid_\(sourceId)_\(category)"
        } else if let sourceUrl {
            key = "url_\(sourceUrl)_\(category)"
        } else {
            key = "unknown_\(UUID().uuidString)"
        }
        return cacheDir.appendingPathComponent("articles_idx").appendingPathComponent("\(key.sha256Hash).json")
    }

    // 名录缓存路径
    private func directoryCacheURL(id: String) -> URL {
        cacheDir.appendingPathComponent("directory").appendingPathComponent("\(id.sha256Hash).json")
    }

    private func directoryIndexURL(sourceId: String?, kind: String) -> URL {
        let key: String
        if let sourceId {
            key = "sid_\(sourceId)_\(kind)"
        } else {
            key = "unknown_\(UUID().uuidString)"
        }
        return cacheDir.appendingPathComponent("directory_idx").appendingPathComponent("\(key.sha256Hash).json")
    }

    // 传承人缓存路径
    private func inheritorCacheURL(id: String) -> URL {
        cacheDir.appendingPathComponent("inheritors").appendingPathComponent("\(id.sha256Hash).json")
    }

    private func inheritorIndexURL(sourceId: String?) -> URL {
        let key: String
        if let sourceId {
            key = "sid_\(sourceId)"
        } else {
            key = "unknown_\(UUID().uuidString)"
        }
        return cacheDir.appendingPathComponent("inheritors_idx").appendingPathComponent("\(key.sha256Hash).json")
    }

    // 通用读写
    private func save<T: Encodable>(_ value: T, to url: URL) {
        do {
            let data = try encoder.encode(value)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        } catch {
            print("[DetailCache] 写入失败: \(url.lastPathComponent), error: \(error)")
        }
    }

    private func load<T: Decodable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
