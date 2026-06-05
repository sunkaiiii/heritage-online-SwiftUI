import XCTest
@testable import HeritageOnline

/// ContentLabels 本地化映射测试
/// 对齐 Android ContentLabelsTest
final class ContentLabelsTests: XCTestCase {

    // MARK: - 内容类型本地化

    func testLocalizedContentTypeArticle() {
        XCTAssertEqual(ContentLabels.localizedContentType("article"), "contentType.article")
    }

    func testLocalizedContentTypeDirectoryItem() {
        XCTAssertEqual(ContentLabels.localizedContentType("directoryItem"), "contentType.directoryItem")
    }

    func testLocalizedContentTypeInheritor() {
        XCTAssertEqual(ContentLabels.localizedContentType("inheritor"), "contentType.inheritor")
    }

    func testLocalizedContentTypeReturnsOriginalForUnknown() {
        // ContentLabels 返回原始值而不是 nil
        XCTAssertEqual(ContentLabels.localizedContentType("unknown"), "unknown")
        XCTAssertEqual(ContentLabels.localizedContentType(""), "")
    }

    // MARK: - 文章分类本地化

    func testLocalizedArticleCategoryNews() {
        XCTAssertEqual(ContentLabels.localizedArticleCategory("news"), "articleCategory.news")
    }

    func testLocalizedArticleCategoryForum() {
        XCTAssertEqual(ContentLabels.localizedArticleCategory("forum"), "articleCategory.forum")
    }

    func testLocalizedArticleCategorySpecialTopic() {
        XCTAssertEqual(ContentLabels.localizedArticleCategory("specialTopic"), "articleCategory.specialTopic")
    }

    func testLocalizedArticleCategoryReturnsOriginalForUnknown() {
        // 未知非空值原样返回，空字符串返回 nil
        XCTAssertEqual(ContentLabels.localizedArticleCategory("unknown"), "unknown")
        XCTAssertNil(ContentLabels.localizedArticleCategory(""))
    }

    // MARK: - 名录 Kind 本地化

    func testLocalizedDirectoryKindNationalProject() {
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("nationalProject"), "directoryKind.nationalProject")
    }

    func testLocalizedDirectoryKindCulturalEcoZone() {
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("culturalEcoZone"), "directoryKind.culturalEcoZone")
    }

    func testLocalizedDirectoryKindProductiveProtectionBase() {
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("productiveProtectionBase"), "directoryKind.productiveProtectionBase")
    }

    func testLocalizedDirectoryKindUnescoEntry() {
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("unescoEntry"), "directoryKind.unescoEntry")
    }

    func testLocalizedDirectoryKindChinaUnescoEntry() {
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("chinaUnescoEntry"), "directoryKind.chinaUnescoEntry")
    }

    func testLocalizedDirectoryKindContractingState() {
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("contractingState"), "directoryKind.contractingState")
    }

    func testLocalizedDirectoryKindReturnsOriginalForUnknown() {
        // 未知非空值原样返回，空字符串返回 nil
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("unknown"), "unknown")
        XCTAssertNil(ContentLabels.localizedDirectoryKind(""))
    }

    // MARK: - 阅读路径来源本地化

    func testLocalizedReadingPathSourceBlendedRecommendation() {
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("blendedRecommendation"), "readingPathSource.blendedRecommendation")
    }

    func testLocalizedReadingPathSourceRelated() {
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("related"), "readingPathSource.related")
    }

    func testLocalizedReadingPathSourceRecommendation() {
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("recommendation"), "readingPathSource.recommendation")
    }

    func testLocalizedReadingPathSourceSemanticRecommendation() {
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("semanticRecommendation"), "readingPathSource.semanticRecommendation")
    }

    func testLocalizedReadingPathSourceGraph() {
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("graph"), "readingPathSource.graph")
    }

    func testLocalizedReadingPathSourceList() {
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("list"), "readingPathSource.list")
    }

    func testLocalizedReadingPathSourceReturnsOriginalForUnknown() {
        // 阅读路径来源返回原始值而不是 nil
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("unknown"), "unknown")
    }

    // MARK: - SearchResultType 映射

    func testSearchResultTypeFromWireNameArticle() {
        XCTAssertEqual(SearchResultType(rawValue: "article"), .article)
    }

    func testSearchResultTypeFromWireNameDirectoryItem() {
        XCTAssertEqual(SearchResultType(rawValue: "directoryItem"), .directoryItem)
    }

    func testSearchResultTypeFromWireNameInheritor() {
        XCTAssertEqual(SearchResultType(rawValue: "inheritor"), .inheritor)
    }

    func testSearchResultTypeFromWireNameReturnsNilForUnknown() {
        XCTAssertNil(SearchResultType(rawValue: "unknown"))
        XCTAssertNil(SearchResultType(rawValue: ""))
    }

    // MARK: - ArticleCategory wireName

    func testArticleCategoryWireNameNews() {
        XCTAssertEqual(ArticleCategory.news.rawValue, "news")
    }

    func testArticleCategoryWireNameForum() {
        XCTAssertEqual(ArticleCategory.forum.rawValue, "forum")
    }

    func testArticleCategoryWireNameSpecialTopic() {
        XCTAssertEqual(ArticleCategory.specialTopic.rawValue, "specialTopic")
    }

    // MARK: - DirectoryItemKind wireName

    func testDirectoryItemKindWireNameNationalProject() {
        XCTAssertEqual(DirectoryItemKind.nationalProject.rawValue, "nationalProject")
    }

    func testDirectoryItemKindWireNameCulturalEcoZone() {
        XCTAssertEqual(DirectoryItemKind.culturalEcoZone.rawValue, "culturalEcoZone")
    }

    func testDirectoryItemKindWireNameProductiveProtectionBase() {
        XCTAssertEqual(DirectoryItemKind.productiveProtectionBase.rawValue, "productiveProtectionBase")
    }

    func testDirectoryItemKindWireNameUnescoEntry() {
        XCTAssertEqual(DirectoryItemKind.unescoEntry.rawValue, "unescoEntry")
    }

    func testDirectoryItemKindWireNameChinaUnescoEntry() {
        XCTAssertEqual(DirectoryItemKind.chinaUnescoEntry.rawValue, "chinaUnescoEntry")
    }

    func testDirectoryItemKindWireNameContractingState() {
        XCTAssertEqual(DirectoryItemKind.contractingState.rawValue, "contractingState")
    }
}
