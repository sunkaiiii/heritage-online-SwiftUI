import Foundation
@testable import HeritageOnline

/// 测试用的空操作 ListCacheRepository
/// 所有方法都不执行实际操作，返回空结果
@MainActor
final class NoOpListCacheRepository: ListCacheRepository {
    func cachedArticles(queryKey: String) async -> [ArticleSummaryDTO] { [] }
    func cacheArticles(_ items: [ArticleListCacheEntity], queryKey: String, loadType: ListLoadType) async {}
    func cacheArticles(_ items: [ArticleListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: ArticleRemoteKeyEntity) async {}
    func articleRemoteKey(queryKey: String) async -> ArticleRemoteKeyEntity? { nil }
    func saveArticleRemoteKey(_ key: ArticleRemoteKeyEntity) async {}

    func cachedDirectoryItems(queryKey: String) async -> [DirectoryItemSummaryDTO] { [] }
    func cacheDirectoryItems(_ items: [DirectoryListCacheEntity], queryKey: String, loadType: ListLoadType) async {}
    func cacheDirectoryItems(_ items: [DirectoryListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: DirectoryRemoteKeyEntity) async {}
    func directoryRemoteKey(queryKey: String) async -> DirectoryRemoteKeyEntity? { nil }
    func saveDirectoryRemoteKey(_ key: DirectoryRemoteKeyEntity) async {}

    func cachedInheritors(queryKey: String) async -> [InheritorSummaryDTO] { [] }
    func cacheInheritors(_ items: [InheritorListCacheEntity], queryKey: String, loadType: ListLoadType) async {}
    func cacheInheritors(_ items: [InheritorListCacheEntity], queryKey: String, loadType: ListLoadType, remoteKey: InheritorRemoteKeyEntity) async {}
    func inheritorRemoteKey(queryKey: String) async -> InheritorRemoteKeyEntity? { nil }
    func saveInheritorRemoteKey(_ key: InheritorRemoteKeyEntity) async {}

    func clearArticles(queryKey: String) async {}
    func clearDirectoryItems(queryKey: String) async {}
    func clearInheritors(queryKey: String) async {}
    func clearAll() async {}
}
