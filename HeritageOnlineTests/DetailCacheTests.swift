import XCTest
@testable import HeritageOnline

/// 详情缓存测试
/// 验证 DTO <-> Entity 转换和缓存读写
@MainActor
final class DetailCacheTests: XCTestCase {

    // MARK: - ArticleDetailDTO <-> ArticleDetailCacheEntity

    func testArticleDetailToCacheEntityAndBack() {
        let original = ArticleDetailDTO(
            id: "test-id-1",
            sourceId: "source-1",
            category: "news",
            title: "测试文章",
            summary: "测试摘要",
            publishedAt: "2024-01-15",
            coverImage: MediaAssetDTO(
                sourceUrl: nil,
                originalUrl: nil,
                displayUrl: "https://example.com/image.jpg",
                thumbnailUrl: nil,
                altText: nil
            ),
            sourceUrl: "https://example.com/article",
            sourceName: "测试来源",
            author: "测试作者",
            editor: nil,
            contentBlocks: [
                ArticleContentBlockDTO(type: .text, text: "正文内容", image: nil),
                ArticleContentBlockDTO(type: .heading, text: "标题", image: nil),
            ],
            relatedArticles: [
                ArticleReferenceDTO(title: "相关文章", detailUrl: nil, sourceId: "ref-1", publishedAt: nil)
            ]
        )

        let lookup = ArticleDetailLookup(articleId: "test-id-1", sourceId: "source-1", sourceUrl: nil, category: .news)
        let entity = original.toCacheEntity(category: lookup.category.rawValue, sourceId: lookup.sourceId, sourceUrl: lookup.sourceUrl)

        XCTAssertEqual(entity.id, "test-id-1")
        XCTAssertEqual(entity.sourceId, "source-1")
        XCTAssertEqual(entity.category, "news")
        XCTAssertEqual(entity.title, "测试文章")
        XCTAssertEqual(entity.summary, "测试摘要")
        XCTAssertEqual(entity.publishedAt, "2024-01-15")
        XCTAssertNotNil(entity.coverImageJson)
        XCTAssertEqual(entity.sourceName, "测试来源")
        XCTAssertEqual(entity.author, "测试作者")

        let restored = entity.toDTO()
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.title, original.title)
        XCTAssertEqual(restored.summary, original.summary)
        XCTAssertEqual(restored.category, original.category)
        XCTAssertEqual(restored.contentBlocks.count, 2)
        XCTAssertEqual(restored.relatedArticles.count, 1)
    }

    // MARK: - DirectoryItemDetailDTO <-> DirectoryDetailCacheEntity

    func testDirectoryDetailToCacheEntityAndBack() {
        let original = DirectoryItemDetailDTO(
            id: "dir-1",
            sourceId: "dir-source-1",
            kind: "nationalProject",
            title: "测试名录",
            summary: "名录摘要",
            category: "传统技艺",
            region: "北京",
            projectCode: "I-1",
            batch: "第一批",
            publishedYear: 2006,
            listType: "国家级",
            nominationType: nil,
            protectionUnit: nil,
            coverImage: MediaAssetDTO(
                sourceUrl: nil,
                originalUrl: nil,
                displayUrl: "https://example.com/dir.jpg",
                thumbnailUrl: nil,
                altText: nil
            ),
            sourceUrl: nil,
            gallery: [
                MediaAssetDTO(sourceUrl: nil, originalUrl: nil, displayUrl: "https://example.com/g1.jpg", thumbnailUrl: nil, altText: nil),
            ],
            contentBlocks: [
                ArticleContentBlockDTO(type: .text, text: "名录正文", image: nil),
            ],
            relatedProjects: [],
            relatedInheritors: [],
            relatedDocuments: []
        )

        let lookup = DirectoryDetailLookup(itemId: "dir-1", sourceId: "dir-source-1", kind: .nationalProject)
        let entity = original.toCacheEntity(kind: lookup.kind.rawValue, sourceId: lookup.sourceId)

        XCTAssertEqual(entity.id, "dir-1")
        XCTAssertEqual(entity.sourceId, "dir-source-1")
        XCTAssertEqual(entity.kind, "nationalProject")
        XCTAssertEqual(entity.title, "测试名录")
        XCTAssertEqual(entity.region, "北京")
        XCTAssertEqual(entity.batch, "第一批")
        XCTAssertEqual(entity.publishedYear, 2006)

        let restored = entity.toDTO()
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.title, original.title)
        XCTAssertEqual(restored.kind, original.kind)
        XCTAssertEqual(restored.gallery.count, 1)
        XCTAssertEqual(restored.contentBlocks.count, 1)
    }

    // MARK: - InheritorDetailDTO <-> InheritorDetailCacheEntity

    func testInheritorDetailToCacheEntityAndBack() {
        let original = InheritorDetailDTO(
            id: "inh-1",
            sourceId: "inh-source-1",
            name: "测试传承人",
            gender: "男",
            birthDateText: "1950年",
            ethnicity: "汉族",
            category: "传统技艺",
            projectCode: "I-1",
            projectName: "测试项目",
            region: "北京",
            batch: "第一批",
            description: "传承人简介",
            coverImage: MediaAssetDTO(
                sourceUrl: nil,
                originalUrl: nil,
                displayUrl: "https://example.com/inh.jpg",
                thumbnailUrl: nil,
                altText: nil
            ),
            sourceUrl: nil,
            contentBlocks: [
                ArticleContentBlockDTO(type: .text, text: "传承人正文", image: nil),
            ],
            relatedProjects: [],
            relatedInheritors: []
        )

        let lookup = InheritorDetailLookup(inheritorId: "inh-1", sourceId: "inh-source-1")
        let entity = original.toCacheEntity(sourceId: lookup.sourceId)

        XCTAssertEqual(entity.id, "inh-1")
        XCTAssertEqual(entity.sourceId, "inh-source-1")
        XCTAssertEqual(entity.name, "测试传承人")
        XCTAssertEqual(entity.gender, "男")
        XCTAssertEqual(entity.ethnicity, "汉族")
        XCTAssertEqual(entity.projectName, "测试项目")

        let restored = entity.toDTO()
        XCTAssertEqual(restored.id, original.id)
        XCTAssertEqual(restored.name, original.name)
        XCTAssertEqual(restored.gender, original.gender)
        XCTAssertEqual(restored.contentBlocks.count, 1)
    }

    // MARK: - 缺失字段容错

    func testArticleDetailHandlesMissingOptionalFields() {
        let original = ArticleDetailDTO(
            id: nil,
            sourceId: nil,
            category: nil,
            title: nil,
            summary: nil,
            publishedAt: nil,
            coverImage: nil,
            sourceUrl: nil,
            sourceName: nil,
            author: nil,
            editor: nil,
            contentBlocks: [],
            relatedArticles: []
        )

        let lookup = ArticleDetailLookup(articleId: nil, sourceId: nil, sourceUrl: nil, category: .news)
        let entity = original.toCacheEntity(category: lookup.category.rawValue, sourceId: lookup.sourceId, sourceUrl: lookup.sourceUrl)

        XCTAssertFalse(entity.id.isEmpty) // 应该生成 UUID
        XCTAssertNil(entity.title)
        XCTAssertNil(entity.summary)

        let restored = entity.toDTO()
        XCTAssertNil(restored.title)
        XCTAssertTrue(restored.contentBlocks.isEmpty)
    }

    // MARK: - 实际缓存读写测试

    private func makeArticleDetail(id: String, title: String) -> ArticleDetailDTO {
        ArticleDetailDTO(
            id: id, sourceId: nil, category: "news", title: title,
            summary: "摘要", publishedAt: "2024-01-01",
            coverImage: nil, sourceUrl: nil, sourceName: nil,
            author: nil, editor: nil, contentBlocks: [], relatedArticles: []
        )
    }

    private func makeDirectoryDetail(id: String, title: String) -> DirectoryItemDetailDTO {
        DirectoryItemDetailDTO(
            id: id, sourceId: nil, kind: "nationalProject", title: title,
            summary: nil, category: nil, region: nil, projectCode: nil,
            batch: nil, publishedYear: nil, listType: nil,
            nominationType: nil, protectionUnit: nil,
            coverImage: nil, sourceUrl: nil,
            gallery: [], contentBlocks: [],
            relatedProjects: [], relatedInheritors: [], relatedDocuments: []
        )
    }

    private func makeInheritorDetail(id: String, name: String) -> InheritorDetailDTO {
        InheritorDetailDTO(
            id: id, sourceId: nil, name: name, gender: nil,
            birthDateText: nil, ethnicity: nil, category: nil,
            projectCode: nil, projectName: nil, region: nil,
            batch: nil, description: nil, coverImage: nil,
            sourceUrl: nil, contentBlocks: [],
            relatedProjects: [], relatedInheritors: []
        )
    }

    func testCacheAndReadArticleDetail() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = makeArticleDetail(id: "detail-1", title: "缓存文章")
        let lookup = ArticleDetailLookup(articleId: "detail-1", sourceId: "src-1", category: .news)

        // 写入
        await cache.cacheArticle(dto, lookup: lookup)

        // 通过 id 读取
        let cached = await cache.cachedArticle(id: "detail-1")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.title, "缓存文章")

        // 通过 sourceId 读取
        let cachedBySource = await cache.cachedArticleBySourceId(sourceId: "src-1", category: "news")
        XCTAssertNotNil(cachedBySource)
        XCTAssertEqual(cachedBySource?.title, "缓存文章")
    }

    func testCacheAndReadDirectoryDetail() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = makeDirectoryDetail(id: "dir-detail-1", title: "缓存名录")
        let lookup = DirectoryDetailLookup(itemId: "dir-detail-1", sourceId: "dir-src-1", kind: .nationalProject)

        await cache.cacheDirectoryItem(dto, lookup: lookup)

        let cached = await cache.cachedDirectoryItem(id: "dir-detail-1")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.title, "缓存名录")

        let cachedBySource = await cache.cachedDirectoryItemBySourceId(sourceId: "dir-src-1", kind: "nationalProject")
        XCTAssertNotNil(cachedBySource)
    }

    func testCacheAndReadInheritorDetail() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = makeInheritorDetail(id: "inh-detail-1", name: "缓存传承人")
        let lookup = InheritorDetailLookup(inheritorId: "inh-detail-1", sourceId: "inh-src-1")

        await cache.cacheInheritor(dto, lookup: lookup)

        let cached = await cache.cachedInheritor(id: "inh-detail-1")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.name, "缓存传承人")

        let cachedBySource = await cache.cachedInheritorBySourceId(sourceId: "inh-src-1")
        XCTAssertNotNil(cachedBySource)
    }

    func testCacheMissReturnsNil() async {
        let cache = DefaultDetailCacheRepository.shared

        let article = await cache.cachedArticle(id: "nonexistent")
        XCTAssertNil(article)

        let directory = await cache.cachedDirectoryItem(id: "nonexistent")
        XCTAssertNil(directory)

        let inheritor = await cache.cachedInheritor(id: "nonexistent")
        XCTAssertNil(inheritor)
    }

    func testDeduplicationOnRewrite() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto1 = makeArticleDetail(id: "rewrite-1", title: "第一版")
        let dto2 = makeArticleDetail(id: "rewrite-1", title: "第二版")
        let lookup = ArticleDetailLookup(articleId: "rewrite-1")

        // 写入第一版
        await cache.cacheArticle(dto1, lookup: lookup)
        let cached1 = await cache.cachedArticle(id: "rewrite-1")
        XCTAssertEqual(cached1?.title, "第一版")

        // 覆写第二版
        await cache.cacheArticle(dto2, lookup: lookup)
        let cached2 = await cache.cachedArticle(id: "rewrite-1")
        XCTAssertEqual(cached2?.title, "第二版")
    }

    // MARK: - DTO sourceId/sourceUrl 兜底索引测试

    /// lookup 只有 articleId，DTO 自带 sourceId，写缓存后可通过 sourceId 读取
    func testArticleCacheIndexesDtoSourceIdWhenLookupOnlyHasId() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = ArticleDetailDTO(
            id: "art-dto-sid",
            sourceId: "art-dto-source-id",
            category: "news",
            title: "DTO有sourceId",
            summary: nil, publishedAt: nil, coverImage: nil,
            sourceUrl: nil, sourceName: nil, author: nil, editor: nil,
            contentBlocks: [], relatedArticles: []
        )
        // lookup 只传 articleId，不传 sourceId
        let lookup = ArticleDetailLookup(articleId: "art-dto-sid", category: .news)

        await cache.cacheArticle(dto, lookup: lookup)

        // 通过 id 读取
        let byId = await cache.cachedArticle(id: "art-dto-sid")
        XCTAssertNotNil(byId)
        XCTAssertEqual(byId?.sourceId, "art-dto-source-id")

        // 通过 DTO 自带的 sourceId 读取
        let bySourceId = await cache.cachedArticleBySourceId(sourceId: "art-dto-source-id", category: "news")
        XCTAssertNotNil(bySourceId)
        XCTAssertEqual(bySourceId?.title, "DTO有sourceId")
    }

    /// lookup 只有 articleId，DTO 自带 sourceUrl，写缓存后可通过 sourceUrl 读取
    func testArticleCacheIndexesDtoSourceUrlWhenLookupOnlyHasId() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = ArticleDetailDTO(
            id: "art-dto-surl",
            sourceId: nil,
            category: "news",
            title: "DTO有sourceUrl",
            summary: nil, publishedAt: nil, coverImage: nil,
            sourceUrl: "https://example.com/dto-article",
            sourceName: nil, author: nil, editor: nil,
            contentBlocks: [], relatedArticles: []
        )
        // lookup 只传 articleId，不传 sourceUrl
        let lookup = ArticleDetailLookup(articleId: "art-dto-surl", category: .news)

        await cache.cacheArticle(dto, lookup: lookup)

        // 通过 DTO 自带的 sourceUrl 读取
        let bySourceUrl = await cache.cachedArticleBySourceUrl(sourceUrl: "https://example.com/dto-article", category: "news")
        XCTAssertNotNil(bySourceUrl)
        XCTAssertEqual(bySourceUrl?.title, "DTO有sourceUrl")
    }

    /// lookup 只有 itemId，DTO 自带 sourceId，写缓存后可通过 sourceId 读取
    func testDirectoryCacheIndexesDtoSourceIdWhenLookupOnlyHasId() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = DirectoryItemDetailDTO(
            id: "dir-dto-sid",
            sourceId: "dir-dto-source-id",
            kind: "nationalProject",
            title: "DTO有sourceId名录",
            summary: nil, category: nil, region: nil, projectCode: nil,
            batch: nil, publishedYear: nil, listType: nil,
            nominationType: nil, protectionUnit: nil,
            coverImage: nil, sourceUrl: nil,
            gallery: [], contentBlocks: [],
            relatedProjects: [], relatedInheritors: [], relatedDocuments: []
        )
        // lookup 只传 itemId，不传 sourceId
        let lookup = DirectoryDetailLookup(itemId: "dir-dto-sid", kind: .nationalProject)

        await cache.cacheDirectoryItem(dto, lookup: lookup)

        // 通过 id 读取
        let byId = await cache.cachedDirectoryItem(id: "dir-dto-sid")
        XCTAssertNotNil(byId)
        XCTAssertEqual(byId?.sourceId, "dir-dto-source-id")

        // 通过 DTO 自带的 sourceId 读取
        let bySourceId = await cache.cachedDirectoryItemBySourceId(sourceId: "dir-dto-source-id", kind: "nationalProject")
        XCTAssertNotNil(bySourceId)
        XCTAssertEqual(bySourceId?.title, "DTO有sourceId名录")
    }

    /// lookup 只有 inheritorId，DTO 自带 sourceId，写缓存后可通过 sourceId 读取
    func testInheritorCacheIndexesDtoSourceIdWhenLookupOnlyHasId() async {
        let cache = DefaultDetailCacheRepository.shared
        let dto = InheritorDetailDTO(
            id: "inh-dto-sid",
            sourceId: "inh-dto-source-id",
            name: "DTO有sourceId传承人",
            gender: nil, birthDateText: nil, ethnicity: nil, category: nil,
            projectCode: nil, projectName: nil, region: nil, batch: nil,
            description: nil, coverImage: nil, sourceUrl: nil,
            contentBlocks: [], relatedProjects: [], relatedInheritors: []
        )
        // lookup 只传 inheritorId，不传 sourceId
        let lookup = InheritorDetailLookup(inheritorId: "inh-dto-sid")

        await cache.cacheInheritor(dto, lookup: lookup)

        // 通过 id 读取
        let byId = await cache.cachedInheritor(id: "inh-dto-sid")
        XCTAssertNotNil(byId)
        XCTAssertEqual(byId?.sourceId, "inh-dto-source-id")

        // 通过 DTO 自带的 sourceId 读取
        let bySourceId = await cache.cachedInheritorBySourceId(sourceId: "inh-dto-source-id")
        XCTAssertNotNil(bySourceId)
        XCTAssertEqual(bySourceId?.name, "DTO有sourceId传承人")
    }
}
