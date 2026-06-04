import Foundation

/// 应用级依赖容器
/// 对齐 Android Hilt SingletonComponent
/// 在 HeritageOnlineApp 创建，通过 @Environment 注入所有 View
@MainActor
@Observable
final class AppDependencies {
    /// 共享实例，用于 ViewModel 默认参数
    static let shared = AppDependencies()

    /// 业务数据 Repository（网络 + 未来缓存）
    let heritageRepository: HeritageRepository

    /// 收藏/最近浏览 Repository
    let savedContentRepository: SavedContentRepository

    /// 阅读路径 Repository
    let readingPathRepository: ReadingPathRepository

    init(
        heritageRepository: HeritageRepository? = nil,
        savedContentRepository: SavedContentRepository? = nil,
        readingPathRepository: ReadingPathRepository? = nil
    ) {
        self.heritageRepository = heritageRepository ?? DefaultHeritageRepository()
        self.savedContentRepository = savedContentRepository ?? DefaultSavedContentRepository.shared
        self.readingPathRepository = readingPathRepository ?? DefaultReadingPathRepository.shared
    }
}
