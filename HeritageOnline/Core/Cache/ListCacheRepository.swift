import Foundation

// MARK: - 列表缓存 Bundle（原子写入：items + remoteKey 合并为单个文件）

/// 文章列表缓存 Bundle
private struct ArticleListCacheBundle: Codable {
    var items: [ArticleListCacheEntity]
    var remoteKey: ArticleRemoteKeyEntity?
}

/// 名录列表缓存 Bundle
private struct DirectoryListCacheBundle: Codable {
    var items: [DirectoryListCacheEntity]
    var remoteKey: DirectoryRemoteKeyEntity?
}

/// 传承人列表缓存 Bundle
private struct InheritorListCacheBundle: Codable {
    var items: [InheritorListCacheEntity]
    var remoteKey: InheritorRemoteKeyEntity?
}

// MARK: - 列表缓存 Repository 协议

/// 列表缓存 Repository 接口
/// 对齐 Android PagingRepository + Room DAO
protocol ListCacheRepository: Sendable {
    // MARK: - 文章列表缓存

    /// 读取缓存的文章列表
    func cachedArticles(queryKey: String) async -> [ArticleSummaryDTO]

    /// 写入文章列表缓存（事务：REFRESH 时清空旧数据再写入）
    func cacheArticles(_ items: [ArticleListCacheEntity], queryKey: String, loadType: ListLoadType) async

    /// 一次性写入文章列表缓存 + remoteKey（原子操作）
    func cacheArticles(_ items: [ArticleListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: ArticleRemoteKeyEntity) async

    /// 读取文章远程分页 Key
    func articleRemoteKey(queryKey: String) async -> ArticleRemoteKeyEntity?

    /// 写入文章远程分页 Key
    func saveArticleRemoteKey(_ key: ArticleRemoteKeyEntity) async

    // MARK: - 名录列表缓存

    /// 读取缓存的名录列表
    func cachedDirectoryItems(queryKey: String) async -> [DirectoryItemSummaryDTO]

    /// 写入名录列表缓存
    func cacheDirectoryItems(_ items: [DirectoryListCacheEntity], queryKey: String, loadType: ListLoadType) async

    /// 一次性写入名录列表缓存 + remoteKey（原子操作）
    func cacheDirectoryItems(_ items: [DirectoryListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: DirectoryRemoteKeyEntity) async

    /// 读取名录远程分页 Key
    func directoryRemoteKey(queryKey: String) async -> DirectoryRemoteKeyEntity?

    /// 写入名录远程分页 Key
    func saveDirectoryRemoteKey(_ key: DirectoryRemoteKeyEntity) async

    // MARK: - 传承人列表缓存

    /// 读取缓存的传承人列表
    func cachedInheritors(queryKey: String) async -> [InheritorSummaryDTO]

    /// 写入传承人列表缓存
    func cacheInheritors(_ items: [InheritorListCacheEntity], queryKey: String, loadType: ListLoadType) async

    /// 一次性写入传承人列表缓存 + remoteKey（原子操作）
    func cacheInheritors(_ items: [InheritorListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: InheritorRemoteKeyEntity) async

    /// 读取传承人远程分页 Key
    func inheritorRemoteKey(queryKey: String) async -> InheritorRemoteKeyEntity?

    /// 写入传承人远程分页 Key
    func saveInheritorRemoteKey(_ key: InheritorRemoteKeyEntity) async

    // MARK: - 清理

    /// 清除指定 queryKey 的文章缓存
    func clearArticles(queryKey: String) async

    /// 清除指定 queryKey 的名录缓存
    func clearDirectoryItems(queryKey: String) async

    /// 清除指定 queryKey 的传承人缓存
    func clearInheritors(queryKey: String) async

    /// 清除所有列表缓存
    func clearAll() async
}

/// 加载类型
/// 对齐 Android LoadType
enum ListLoadType {
    case refresh  // 清空旧数据，重新加载
    case append   // 追加到现有列表
}

// MARK: - 列表缓存 Repository 默认实现

/// 使用基于文件系统的 JSON 缓存
/// 每个 queryKey 对应一个 Bundle 文件（items + remoteKey），保证原子写入
/// 文件名使用 SHA256 hash，避免中文字符碰撞
@MainActor
final class DefaultListCacheRepository: ListCacheRepository {
    static let shared = DefaultListCacheRepository()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.sortedKeys]
        return e
    }()

    private let decoder = JSONDecoder()
    private let cacheDir: URL

    private init() {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDir = base.appendingPathComponent("ListCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    // MARK: - 文章列表缓存

    func cachedArticles(queryKey: String) async -> [ArticleSummaryDTO] {
        let url = articlesCacheURL(queryKey: queryKey)
        guard let bundle: ArticleListCacheBundle = load(from: url) else { return [] }
        return bundle.items
            .sorted { ($0.page, $0.positionInPage) < ($1.page, $1.positionInPage) }
            .map { $0.toDTO() }
    }

    func cacheArticles(_ items: [ArticleListCacheEntity], queryKey: String, loadType: ListLoadType) async {
        let url = articlesCacheURL(queryKey: queryKey)

        switch loadType {
        case .refresh:
            let bundle = ArticleListCacheBundle(items: items, remoteKey: nil)
            save(bundle, to: url)
        case .append:
            var bundle: ArticleListCacheBundle = load(from: url) ?? ArticleListCacheBundle(items: [], remoteKey: nil)
            let existingIds = Set(bundle.items.map(\.id))
            let newItems = items.filter { !existingIds.contains($0.id) }
            bundle.items.append(contentsOf: newItems)
            save(bundle, to: url)
        }
    }

    func cacheArticles(_ items: [ArticleListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: ArticleRemoteKeyEntity) async {
        let url = articlesCacheURL(queryKey: queryKey)

        switch loadType {
        case .refresh:
            let bundle = ArticleListCacheBundle(items: items, remoteKey: remoteKey)
            save(bundle, to: url)
        case .append:
            var bundle: ArticleListCacheBundle = load(from: url) ?? ArticleListCacheBundle(items: [], remoteKey: nil)
            let existingIds = Set(bundle.items.map(\.id))
            let newItems = items.filter { !existingIds.contains($0.id) }
            bundle.items.append(contentsOf: newItems)
            bundle.remoteKey = remoteKey
            save(bundle, to: url)
        }
    }

    func articleRemoteKey(queryKey: String) async -> ArticleRemoteKeyEntity? {
        let url = articlesCacheURL(queryKey: queryKey)
        let bundle: ArticleListCacheBundle? = load(from: url)
        return bundle?.remoteKey
    }

    func saveArticleRemoteKey(_ key: ArticleRemoteKeyEntity) async {
        let url = articlesCacheURL(queryKey: key.queryKey)
        var bundle: ArticleListCacheBundle = load(from: url) ?? ArticleListCacheBundle(items: [], remoteKey: nil)
        bundle.remoteKey = key
        save(bundle, to: url)
    }

    // MARK: - 名录列表缓存

    func cachedDirectoryItems(queryKey: String) async -> [DirectoryItemSummaryDTO] {
        let url = directoryCacheURL(queryKey: queryKey)
        guard let bundle: DirectoryListCacheBundle = load(from: url) else { return [] }
        return bundle.items
            .sorted { ($0.page, $0.positionInPage) < ($1.page, $1.positionInPage) }
            .map { $0.toDTO() }
    }

    func cacheDirectoryItems(_ items: [DirectoryListCacheEntity], queryKey: String, loadType: ListLoadType) async {
        let url = directoryCacheURL(queryKey: queryKey)

        switch loadType {
        case .refresh:
            let bundle = DirectoryListCacheBundle(items: items, remoteKey: nil)
            save(bundle, to: url)
        case .append:
            var bundle: DirectoryListCacheBundle = load(from: url) ?? DirectoryListCacheBundle(items: [], remoteKey: nil)
            let existingIds = Set(bundle.items.map(\.id))
            let newItems = items.filter { !existingIds.contains($0.id) }
            bundle.items.append(contentsOf: newItems)
            save(bundle, to: url)
        }
    }

    func cacheDirectoryItems(_ items: [DirectoryListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: DirectoryRemoteKeyEntity) async {
        let url = directoryCacheURL(queryKey: queryKey)

        switch loadType {
        case .refresh:
            let bundle = DirectoryListCacheBundle(items: items, remoteKey: remoteKey)
            save(bundle, to: url)
        case .append:
            var bundle: DirectoryListCacheBundle = load(from: url) ?? DirectoryListCacheBundle(items: [], remoteKey: nil)
            let existingIds = Set(bundle.items.map(\.id))
            let newItems = items.filter { !existingIds.contains($0.id) }
            bundle.items.append(contentsOf: newItems)
            bundle.remoteKey = remoteKey
            save(bundle, to: url)
        }
    }

    func directoryRemoteKey(queryKey: String) async -> DirectoryRemoteKeyEntity? {
        let url = directoryCacheURL(queryKey: queryKey)
        let bundle: DirectoryListCacheBundle? = load(from: url)
        return bundle?.remoteKey
    }

    func saveDirectoryRemoteKey(_ key: DirectoryRemoteKeyEntity) async {
        let url = directoryCacheURL(queryKey: key.queryKey)
        var bundle: DirectoryListCacheBundle = load(from: url) ?? DirectoryListCacheBundle(items: [], remoteKey: nil)
        bundle.remoteKey = key
        save(bundle, to: url)
    }

    // MARK: - 传承人列表缓存

    func cachedInheritors(queryKey: String) async -> [InheritorSummaryDTO] {
        let url = inheritorCacheURL(queryKey: queryKey)
        guard let bundle: InheritorListCacheBundle = load(from: url) else { return [] }
        return bundle.items
            .sorted { ($0.page, $0.positionInPage) < ($1.page, $1.positionInPage) }
            .map { $0.toDTO() }
    }

    func cacheInheritors(_ items: [InheritorListCacheEntity], queryKey: String, loadType: ListLoadType) async {
        let url = inheritorCacheURL(queryKey: queryKey)

        switch loadType {
        case .refresh:
            let bundle = InheritorListCacheBundle(items: items, remoteKey: nil)
            save(bundle, to: url)
        case .append:
            var bundle: InheritorListCacheBundle = load(from: url) ?? InheritorListCacheBundle(items: [], remoteKey: nil)
            let existingIds = Set(bundle.items.map(\.id))
            let newItems = items.filter { !existingIds.contains($0.id) }
            bundle.items.append(contentsOf: newItems)
            save(bundle, to: url)
        }
    }

    func cacheInheritors(_ items: [InheritorListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: InheritorRemoteKeyEntity) async {
        let url = inheritorCacheURL(queryKey: queryKey)

        switch loadType {
        case .refresh:
            let bundle = InheritorListCacheBundle(items: items, remoteKey: remoteKey)
            save(bundle, to: url)
        case .append:
            var bundle: InheritorListCacheBundle = load(from: url) ?? InheritorListCacheBundle(items: [], remoteKey: nil)
            let existingIds = Set(bundle.items.map(\.id))
            let newItems = items.filter { !existingIds.contains($0.id) }
            bundle.items.append(contentsOf: newItems)
            bundle.remoteKey = remoteKey
            save(bundle, to: url)
        }
    }

    func inheritorRemoteKey(queryKey: String) async -> InheritorRemoteKeyEntity? {
        let url = inheritorCacheURL(queryKey: queryKey)
        let bundle: InheritorListCacheBundle? = load(from: url)
        return bundle?.remoteKey
    }

    func saveInheritorRemoteKey(_ key: InheritorRemoteKeyEntity) async {
        let url = inheritorCacheURL(queryKey: key.queryKey)
        var bundle: InheritorListCacheBundle = load(from: url) ?? InheritorListCacheBundle(items: [], remoteKey: nil)
        bundle.remoteKey = key
        save(bundle, to: url)
    }

    // MARK: - 清理

    func clearArticles(queryKey: String) async {
        try? FileManager.default.removeItem(at: articlesCacheURL(queryKey: queryKey))
    }

    func clearDirectoryItems(queryKey: String) async {
        try? FileManager.default.removeItem(at: directoryCacheURL(queryKey: queryKey))
    }

    func clearInheritors(queryKey: String) async {
        try? FileManager.default.removeItem(at: inheritorCacheURL(queryKey: queryKey))
    }

    func clearAll() async {
        try? FileManager.default.removeItem(at: cacheDir)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    // MARK: - 内部方法

    /// 文件名使用 SHA256 hash，避免中文字符和非 ASCII 字符碰撞
    private func articlesCacheURL(queryKey: String) -> URL {
        cacheDir.appendingPathComponent("articles").appendingPathComponent("\(queryKey.sha256Hash).json")
    }

    private func directoryCacheURL(queryKey: String) -> URL {
        cacheDir.appendingPathComponent("directory").appendingPathComponent("\(queryKey.sha256Hash).json")
    }

    private func inheritorCacheURL(queryKey: String) -> URL {
        cacheDir.appendingPathComponent("inheritors").appendingPathComponent("\(queryKey.sha256Hash).json")
    }

    private func save<T: Encodable>(_ value: T, to url: URL) {
        do {
            let data = try encoder.encode(value)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url, options: .atomic)
        } catch {
            print("[ListCache] 写入失败: \(url.lastPathComponent), error: \(error)")
        }
    }

    private func load<T: Decodable>(from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
}
