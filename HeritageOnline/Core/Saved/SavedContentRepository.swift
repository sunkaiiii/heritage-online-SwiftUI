import Foundation

/// SavedContent Repository 接口
/// 对齐 Android SavedContentRepository
protocol SavedContentRepository: Sendable {
    /// 获取所有收藏
    func favorites() async -> [SavedContent]

    /// 获取所有最近浏览
    func recentlyViewed() async -> [SavedContent]

    /// 切换收藏状态
    func toggleFavorite(_ snapshot: SavedContent) async

    /// 记录浏览
    func recordViewed(_ snapshot: SavedContent) async

    /// 移除收藏
    func removeFavorite(_ contentKey: String) async

    /// 移除单条浏览记录
    func removeRecent(_ contentKey: String) async

    /// 清空所有浏览记录
    func clearRecent() async

    /// 查询是否已收藏
    func isFavorite(_ contentKey: String) async -> Bool
}

/// SavedContent Repository 默认实现
/// 使用 UserDefaults 存储（第一阶段，后续可迁移到 SwiftData/SQLite）
/// @MainActor 确保读写串行化，避免并发竞争
@MainActor
final class DefaultSavedContentRepository: SavedContentRepository {
    static let shared = DefaultSavedContentRepository()

    private let favoritesKey = "saved_content_favorites"
    private let maxRecent = 100

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    // MARK: - 读取

    func favorites() async -> [SavedContent] {
        let all = loadAll()
        return all.filter { $0.isFavorite }.sorted { ($0.favoritedAt ?? .distantPast) > ($1.favoritedAt ?? .distantPast) }
    }

    func recentlyViewed() async -> [SavedContent] {
        let all = loadAll()
        return all.filter { $0.lastViewedAt != nil }.sorted { ($0.lastViewedAt ?? .distantPast) > ($1.lastViewedAt ?? .distantPast) }
    }

    func isFavorite(_ contentKey: String) async -> Bool {
        let all = loadAll()
        return all.first(where: { $0.contentKey == contentKey })?.isFavorite ?? false
    }

    // MARK: - 写入

    func toggleFavorite(_ snapshot: SavedContent) async {
        var all = loadAll()
        let key = snapshot.contentKey

        if let index = all.firstIndex(where: { $0.contentKey == key }) {
            if all[index].isFavorite {
                // 取消收藏
                all[index].isFavorite = false
                all[index].favoritedAt = nil
            } else {
                // 收藏
                all[index].isFavorite = true
                all[index].favoritedAt = Date()
            }
        } else {
            // 新记录
            var new = snapshot
            new.isFavorite = true
            new.favoritedAt = Date()
            all.append(new)
        }

        saveAll(all)
    }

    func recordViewed(_ snapshot: SavedContent) async {
        var all = loadAll()
        let key = snapshot.contentKey

        if let index = all.firstIndex(where: { $0.contentKey == key }) {
            // 更新浏览时间
            all[index].lastViewedAt = Date()
            // 更新展示字段（可能刷新了）
            all[index].title = snapshot.title
            all[index].subtitle = snapshot.subtitle
            all[index].summary = snapshot.summary
            all[index].imageUrl = snapshot.imageUrl
        } else {
            // 新记录
            var new = snapshot
            new.lastViewedAt = Date()
            all.append(new)
        }

        // 裁剪到上限
        trimRecent(&all)
        saveAll(all)
    }

    func removeFavorite(_ contentKey: String) async {
        var all = loadAll()
        if let index = all.firstIndex(where: { $0.contentKey == contentKey }) {
            all[index].isFavorite = false
            all[index].favoritedAt = nil
            // 如果也没有浏览记录，移除整条
            if all[index].lastViewedAt == nil {
                all.remove(at: index)
            }
        }
        saveAll(all)
    }

    func removeRecent(_ contentKey: String) async {
        var all = loadAll()
        if let index = all.firstIndex(where: { $0.contentKey == contentKey }) {
            all[index].lastViewedAt = nil
            // 如果也没有收藏，移除整条
            if !all[index].isFavorite {
                all.remove(at: index)
            }
        }
        saveAll(all)
    }

    func clearRecent() async {
        var all = loadAll()
        for i in all.indices {
            all[i].lastViewedAt = nil
        }
        // 移除既不收藏也无浏览的记录
        all.removeAll { !$0.isFavorite && $0.lastViewedAt == nil }
        saveAll(all)
    }

    // MARK: - 内部方法

    private func loadAll() -> [SavedContent] {
        guard let data = defaults.data(forKey: favoritesKey) else { return [] }
        return (try? decoder.decode([SavedContent].self, from: data)) ?? []
    }

    private func saveAll(_ items: [SavedContent]) {
        if let data = try? encoder.encode(items) {
            defaults.set(data, forKey: favoritesKey)
        }
    }

    private func trimRecent(_ items: inout [SavedContent]) {
        let recentItems = items.filter { $0.lastViewedAt != nil }.sorted { ($0.lastViewedAt ?? .distantPast) > ($1.lastViewedAt ?? .distantPast) }
        if recentItems.count > maxRecent {
            let toTrim = recentItems.suffix(from: maxRecent)
            for item in toTrim {
                if !item.isFavorite, let idx = items.firstIndex(where: { $0.contentKey == item.contentKey }) {
                    items[idx].lastViewedAt = nil
                }
            }
        }
    }
}
