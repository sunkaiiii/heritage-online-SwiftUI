import XCTest
@testable import HeritageOnline

/// 列表缓存测试
/// 验证 queryKey 计算、DTO <-> Entity 转换和缓存读写
@MainActor
final class ListCacheTests: XCTestCase {

    // MARK: - QueryKey 计算

    func testArticleQueryKey() {
        let query1 = ArticleQuery(category: .news, page: 1, pageSize: 20)
        XCTAssertEqual(query1.queryKey, "news||")

        let query2 = ArticleQuery(category: .forum, page: 1, pageSize: 20, year: 2024, keywords: "测试")
        XCTAssertEqual(query2.queryKey, "forum|2024|测试")

        let query3 = ArticleQuery(category: .specialTopic, page: 1, pageSize: 20, keywords: "关键词")
        XCTAssertEqual(query3.queryKey, "specialTopic||关键词")
    }

    func testDirectoryItemQueryKey() {
        let query1 = DirectoryItemQuery(kind: .nationalProject, page: 1, pageSize: 20)
        XCTAssertEqual(query1.queryKey, "nationalProject|||||")

        let query2 = DirectoryItemQuery(
            kind: .culturalEcoZone,
            page: 1,
            pageSize: 20,
            keywords: "测试",
            region: "北京",
            category: "传统技艺",
            year: 2024,
            listType: "国家级"
        )
        XCTAssertEqual(query2.queryKey, "culturalEcoZone|北京|传统技艺|2024|测试|国家级")
    }

    func testInheritorQueryKey() {
        let query1 = InheritorQuery(page: 1, pageSize: 20)
        XCTAssertEqual(query1.queryKey, "||||")

        let query2 = InheritorQuery(
            page: 1,
            pageSize: 20,
            keywords: "测试",
            region: "北京",
            category: "传统技艺",
            year: 2024,
            gender: "男"
        )
        XCTAssertEqual(query2.queryKey, "北京|传统技艺|2024|男|测试")
    }

    // MARK: - ArticleSummaryDTO <-> ArticleListCacheEntity

    func testArticleSummaryToListEntityAndBack() {
        let original = ArticleSummaryDTO(
            id: "article-1",
            category: "news",
            title: "测试文章",
            summary: "文章摘要",
            publishedAt: "2024-01-15",
            coverImage: MediaAssetDTO(
                sourceUrl: nil,
                originalUrl: nil,
                displayUrl: "https://example.com/img.jpg",
                thumbnailUrl: nil,
                altText: nil
            ),
            sourceUrl: nil
        )

        let query = ArticleQuery(category: .news, page: 1, pageSize: 20)
        let entity = original.toListEntity(query: query, page: 1, positionInPage: 0)

        XCTAssertEqual(entity.id, "article-1")
        XCTAssertEqual(entity.queryKey, "news||")
        XCTAssertEqual(entity.category, "news")
        XCTAssertEqual(entity.title, "测试文章")
        XCTAssertEqual(entity.page, 1)
        XCTAssertEqual(entity.positionInPage, 0)

        let restored = entity.toDTO()
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.title, original.title)
        XCTAssertEqual(restored.category, original.category)
    }

    // MARK: - DirectoryItemSummaryDTO <-> DirectoryListCacheEntity

    func testDirectoryItemSummaryToListEntityAndBack() {
        let original = DirectoryItemSummaryDTO(
            id: "dir-1",
            kind: "nationalProject",
            title: "测试名录",
            summary: "名录摘要",
            category: "传统技艺",
            region: "北京",
            projectCode: "I-1",
            batch: "第一批",
            publishedYear: 2006,
            listType: "国家级",
            coverImage: nil,
            sourceUrl: nil
        )

        let query = DirectoryItemQuery(kind: .nationalProject, page: 1, pageSize: 20)
        let entity = original.toListEntity(query: query, page: 1, positionInPage: 0)

        XCTAssertEqual(entity.id, "dir-1")
        XCTAssertEqual(entity.queryKey, "nationalProject|||||")
        XCTAssertEqual(entity.kind, "nationalProject")
        XCTAssertEqual(entity.title, "测试名录")
        XCTAssertEqual(entity.region, "北京")
        XCTAssertEqual(entity.publishedYear, 2006)

        let restored = entity.toDTO()
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.title, original.title)
        XCTAssertEqual(restored.kind, original.kind)
    }

    // MARK: - InheritorSummaryDTO <-> InheritorListCacheEntity

    func testInheritorSummaryToListEntityAndBack() {
        let original = InheritorSummaryDTO(
            id: "inh-1",
            name: "测试传承人",
            gender: "男",
            birthDateText: "1950年",
            ethnicity: "汉族",
            category: "传统技艺",
            projectCode: "I-1",
            projectName: "测试项目",
            region: "北京",
            batch: "第一批",
            description: "简介",
            coverImage: nil,
            sourceUrl: nil
        )

        let query = InheritorQuery(page: 1, pageSize: 20)
        let entity = original.toListEntity(query: query, page: 1, positionInPage: 0)

        XCTAssertEqual(entity.id, "inh-1")
        XCTAssertEqual(entity.queryKey, "||||")
        XCTAssertEqual(entity.name, "测试传承人")
        XCTAssertEqual(entity.gender, "男")
        XCTAssertEqual(entity.region, "北京")

        let restored = entity.toDTO()
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.name, original.name)
        XCTAssertEqual(restored.gender, original.gender)
    }

    // MARK: - 缺失 ID 生成

    func testArticleEntityGeneratesIdWhenMissing() {
        let original = ArticleSummaryDTO(
            id: nil,
            category: "news",
            title: "测试",
            summary: nil,
            publishedAt: nil,
            coverImage: nil,
            sourceUrl: nil
        )

        let query = ArticleQuery(category: .news, page: 1, pageSize: 20)
        let entity = original.toListEntity(query: query, page: 1, positionInPage: 5)

        // 应该使用 queryKey-page-positionInPage 作为 ID
        XCTAssertEqual(entity.id, "news||-1-5")
    }

    func testArticleEntityUsesSourceUrlAsIdWhenBothIdAndSourceUrlMissing() {
        let original = ArticleSummaryDTO(
            id: nil,
            category: "news",
            title: "测试",
            summary: nil,
            publishedAt: nil,
            coverImage: nil,
            sourceUrl: "https://example.com/article"
        )

        let query = ArticleQuery(category: .news, page: 1, pageSize: 20)
        let entity = original.toListEntity(query: query, page: 1, positionInPage: 0)

        XCTAssertEqual(entity.id, "https://example.com/article")
    }

    // MARK: - 实际缓存读写测试

    private func makeTestArticle(id: String, title: String) -> ArticleSummaryDTO {
        ArticleSummaryDTO(
            id: id, category: "news", title: title, summary: nil,
            publishedAt: nil, coverImage: nil, sourceUrl: nil
        )
    }

    func testCacheArticlesRefresh() async {
        let cache = DefaultListCacheRepository.shared
        let queryKey = "test-cache-refresh"
        let query = ArticleQuery(category: .news, page: 1)

        // 写入 page 1
        let items1 = (0..<3).map { i in
            makeTestArticle(id: "a\(i)", title: "文章\(i)").toListEntity(query: query, page: 1, positionInPage: i)
        }
        await cache.cacheArticles(items1, queryKey: queryKey, loadType: .refresh)

        // 读取
        let cached1 = await cache.cachedArticles(queryKey: queryKey)
        XCTAssertEqual(cached1.count, 3)

        // Refresh 应替换旧数据
        let items2 = [makeTestArticle(id: "b0", title: "新文章").toListEntity(query: query, page: 1, positionInPage: 0)]
        await cache.cacheArticles(items2, queryKey: queryKey, loadType: .refresh)

        let cached2 = await cache.cachedArticles(queryKey: queryKey)
        XCTAssertEqual(cached2.count, 1)
        XCTAssertEqual(cached2.first?.title, "新文章")

        // 清理
        await cache.clearArticles(queryKey: queryKey)
    }

    func testCacheArticlesAppend() async {
        let cache = DefaultListCacheRepository.shared
        let queryKey = "test-cache-append"
        let query = ArticleQuery(category: .news, page: 1)

        // 写入 page 1
        let items1 = (0..<2).map { i in
            makeTestArticle(id: "a\(i)", title: "文章\(i)").toListEntity(query: query, page: 1, positionInPage: i)
        }
        await cache.cacheArticles(items1, queryKey: queryKey, loadType: .refresh)
        let count1 = await cache.cachedArticles(queryKey: queryKey).count
        XCTAssertEqual(count1, 2)

        // Append page 2（去重）
        let items2 = [makeTestArticle(id: "a2", title: "文章2").toListEntity(query: query, page: 2, positionInPage: 2)]
        await cache.cacheArticles(items2, queryKey: queryKey, loadType: .append)
        let count2 = await cache.cachedArticles(queryKey: queryKey).count
        XCTAssertEqual(count2, 3)

        // Append 重复 id 不新增
        await cache.cacheArticles(items1, queryKey: queryKey, loadType: .append)
        let count3 = await cache.cachedArticles(queryKey: queryKey).count
        XCTAssertEqual(count3, 3)

        // 清理
        await cache.clearArticles(queryKey: queryKey)
    }

    func testRemoteKeySaveAndLoad() async {
        let cache = DefaultListCacheRepository.shared
        let queryKey = "test-remote-key"

        // 初始无 remoteKey
        let initial = await cache.articleRemoteKey(queryKey: queryKey)
        XCTAssertNil(initial)

        // 写入 remoteKey
        let key = ArticleRemoteKeyEntity(queryKey: queryKey, nextPage: 2, hasMore: true)
        await cache.saveArticleRemoteKey(key)

        // 读取
        let loaded = await cache.articleRemoteKey(queryKey: queryKey)
        XCTAssertEqual(loaded?.nextPage, 2)
        XCTAssertTrue(loaded?.hasMore ?? false)

        // 更新 remoteKey
        let updatedKey = ArticleRemoteKeyEntity(queryKey: queryKey, nextPage: nil, hasMore: false)
        await cache.saveArticleRemoteKey(updatedKey)
        let loaded2 = await cache.articleRemoteKey(queryKey: queryKey)
        XCTAssertNil(loaded2?.nextPage)
        XCTAssertFalse(loaded2?.hasMore ?? true)

        // 清理
        await cache.clearArticles(queryKey: queryKey)
    }

    func testDifferentQueryKeysDontMix() async {
        let cache = DefaultListCacheRepository.shared
        let query = ArticleQuery(category: .news, page: 1)

        // queryKey A: 写入 2 篇
        let itemsA = (0..<2).map { i in
            makeTestArticle(id: "a\(i)", title: "A\(i)").toListEntity(query: query, page: 1, positionInPage: i)
        }
        await cache.cacheArticles(itemsA, queryKey: "keyA", loadType: .refresh)

        // queryKey B: 写入 1 篇
        let itemsB = [makeTestArticle(id: "b0", title: "B0").toListEntity(query: query, page: 1, positionInPage: 0)]
        await cache.cacheArticles(itemsB, queryKey: "keyB", loadType: .refresh)

        // 互不影响
        let countA = await cache.cachedArticles(queryKey: "keyA").count
        let countB = await cache.cachedArticles(queryKey: "keyB").count
        XCTAssertEqual(countA, 2)
        XCTAssertEqual(countB, 1)

        // 清理
        await cache.clearArticles(queryKey: "keyA")
        await cache.clearArticles(queryKey: "keyB")
    }

    func testClearRemovesCache() async {
        let cache = DefaultListCacheRepository.shared
        let queryKey = "test-clear"
        let query = ArticleQuery(category: .news, page: 1)

        let items = [makeTestArticle(id: "a0", title: "文章").toListEntity(query: query, page: 1, positionInPage: 0)]
        await cache.cacheArticles(items, queryKey: queryKey, loadType: .refresh)
        await cache.saveArticleRemoteKey(ArticleRemoteKeyEntity(queryKey: queryKey, nextPage: 2, hasMore: true))
        let countBefore = await cache.cachedArticles(queryKey: queryKey).count
        let keyBefore = await cache.articleRemoteKey(queryKey: queryKey)
        XCTAssertEqual(countBefore, 1)
        XCTAssertNotNil(keyBefore)

        // 清理
        await cache.clearArticles(queryKey: queryKey)
        let countAfter = await cache.cachedArticles(queryKey: queryKey).count
        let keyAfter = await cache.articleRemoteKey(queryKey: queryKey)
        XCTAssertEqual(countAfter, 0)
        XCTAssertNil(keyAfter)
    }

    func testChineseQueryKeyDoesNotCollide() async {
        let cache = DefaultListCacheRepository.shared
        let query = ArticleQuery(category: .news, page: 1)

        // 写入 queryKey "北京"
        let beijingItems = [makeTestArticle(id: "b1", title: "北京文章").toListEntity(query: ArticleQuery(category: .news, page: 1, keywords: "北京"), page: 1, positionInPage: 0)]
        await cache.cacheArticles(beijingItems, queryKey: ArticleQuery(category: .news, page: 1, keywords: "北京").queryKey, loadType: .refresh)

        // 写入 queryKey "上海"
        let shanghaiItems = [makeTestArticle(id: "s1", title: "上海文章").toListEntity(query: ArticleQuery(category: .news, page: 1, keywords: "上海"), page: 1, positionInPage: 0)]
        await cache.cacheArticles(shanghaiItems, queryKey: ArticleQuery(category: .news, page: 1, keywords: "上海").queryKey, loadType: .refresh)

        // 两个 queryKey 不应碰撞
        let beijingCached = await cache.cachedArticles(queryKey: ArticleQuery(category: .news, page: 1, keywords: "北京").queryKey)
        let shanghaiCached = await cache.cachedArticles(queryKey: ArticleQuery(category: .news, page: 1, keywords: "上海").queryKey)
        XCTAssertEqual(beijingCached.count, 1)
        XCTAssertEqual(shanghaiCached.count, 1)
        XCTAssertEqual(beijingCached.first?.title, "北京文章")
        XCTAssertEqual(shanghaiCached.first?.title, "上海文章")

        // 清理
        await cache.clearArticles(queryKey: ArticleQuery(category: .news, page: 1, keywords: "北京").queryKey)
        await cache.clearArticles(queryKey: ArticleQuery(category: .news, page: 1, keywords: "上海").queryKey)
    }
}
