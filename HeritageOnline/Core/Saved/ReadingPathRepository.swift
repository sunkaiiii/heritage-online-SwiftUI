import Foundation

/// ReadingPath Repository 接口
/// 对齐 Android ReadingPathRepository
protocol ReadingPathRepository: Sendable {
    /// 获取所有阅读路径事件
    func events() async -> [ReadingPathEvent]

    /// 记录阅读路径
    func record(_ event: ReadingPathEvent) async

    /// 清空所有阅读路径
    func clearAll() async
}

/// ReadingPath Repository 默认实现
final class DefaultReadingPathRepository: ReadingPathRepository, @unchecked Sendable {
    static let shared = DefaultReadingPathRepository()

    private let storageKey = "reading_path_events"
    private let maxEvents = 50

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private init() {}

    func events() async -> [ReadingPathEvent] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return (try? decoder.decode([ReadingPathEvent].self, from: data)) ?? []
    }

    func record(_ event: ReadingPathEvent) async {
        var all = await events()

        // 检查是否已存在相同路径
        if let index = all.firstIndex(where: { $0.id == event.id }) {
            // 更新 createdAt
            all[index].createdAt = Date()
        } else {
            // 新增
            all.insert(event, at: 0)
        }

        // 裁剪到上限
        if all.count > maxEvents {
            all = Array(all.prefix(maxEvents))
        }

        saveAll(all)
    }

    func clearAll() async {
        defaults.removeObject(forKey: storageKey)
    }

    private func saveAll(_ items: [ReadingPathEvent]) {
        if let data = try? encoder.encode(items) {
            defaults.set(data, forKey: storageKey)
        }
    }
}
