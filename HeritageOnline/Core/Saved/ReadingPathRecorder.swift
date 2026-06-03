import Foundation

/// 阅读路径记录器
/// 用于详情页跨内容跳转时记录路径
final class ReadingPathRecorder: @unchecked Sendable {
    static let shared = ReadingPathRecorder()

    private let repository: ReadingPathRepository

    init(repository: ReadingPathRepository = DefaultReadingPathRepository.shared) {
        self.repository = repository
    }

    /// 记录阅读路径
    /// - Parameters:
    ///   - from: 来源内容 (type, id, title)
    ///   - to: 目标内容
    ///   - source: 跳转来源
    func record(
        from: (type: SavedContentType, id: String, title: String),
        toType: SavedContentType,
        toId: String,
        toTitle: String,
        source: ReadingPathSource,
        toCategory: String? = nil,
        toKind: String? = nil,
        toSourceId: String? = nil,
        toSourceUrl: String? = nil,
        toSubtitle: String? = nil,
        toImageUrl: String? = nil
    ) async {
        // 跳过 collection 和 topic（我的页无法回跳）
        guard toType == .article || toType == .directoryItem || toType == .inheritor else {
            return
        }

        let id = ReadingPathEvent.computeId(
            fromType: from.type,
            fromId: from.id,
            toType: toType,
            toId: toId,
            source: source
        )

        let event = ReadingPathEvent(
            id: id,
            fromType: from.type,
            fromId: from.id,
            fromTitle: from.title,
            toType: toType,
            toId: toId,
            toTitle: toTitle,
            source: source,
            toCategory: toCategory,
            toKind: toKind,
            toSourceId: toSourceId,
            toSourceUrl: toSourceUrl,
            toSubtitle: toSubtitle,
            toImageUrl: toImageUrl,
            createdAt: Date()
        )

        await repository.record(event)
    }
}
