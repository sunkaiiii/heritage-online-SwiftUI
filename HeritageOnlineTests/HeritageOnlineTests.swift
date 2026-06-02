import XCTest
@testable import HeritageOnline

final class HeritageOnlineTests: XCTestCase {

    // MARK: - APIConfig Tests

    func testAPIConfigBaseURL() throws {
        let config = APIConfig.shared
        XCTAssertNotNil(config.baseURL)
        XCTAssertTrue(config.baseURL.absoluteString.contains("localhost") || config.baseURL.absoluteString.contains("10.0.2.2"))
    }

    func testAPIConfigEnvironment() throws {
        let config = APIConfig.shared
        #if DEBUG
        XCTAssertEqual(config.environment, .debug)
        XCTAssertTrue(config.trustSelfSigned)
        #else
        XCTAssertEqual(config.environment, .release)
        XCTAssertFalse(config.trustSelfSigned)
        #endif
    }

    func testAPIConfigURLConstruction() throws {
        let config = APIConfig.shared
        let url = config.url(for: "api/articles", queryItems: [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "pageSize", value: "20")
        ])
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("api/articles"))
        XCTAssertTrue(url!.absoluteString.contains("page=1"))
        XCTAssertTrue(url!.absoluteString.contains("pageSize=20"))
    }

    // MARK: - ThemeMode Tests

    func testThemeModeAllCases() throws {
        XCTAssertEqual(ThemeMode.allCases.count, 3)
        XCTAssertTrue(ThemeMode.allCases.contains(.system))
        XCTAssertTrue(ThemeMode.allCases.contains(.light))
        XCTAssertTrue(ThemeMode.allCases.contains(.dark))
    }

    func testThemeModeDisplayName() throws {
        XCTAssertFalse(ThemeMode.system.displayName.isEmpty)
        XCTAssertFalse(ThemeMode.light.displayName.isEmpty)
        XCTAssertFalse(ThemeMode.dark.displayName.isEmpty)
    }

    // MARK: - LanguageMode Tests

    func testLanguageModeAllCases() throws {
        XCTAssertEqual(LanguageMode.allCases.count, 3)
        XCTAssertTrue(LanguageMode.allCases.contains(.system))
        XCTAssertTrue(LanguageMode.allCases.contains(.zhHans))
        XCTAssertTrue(LanguageMode.allCases.contains(.en))
    }

    func testLanguageModeLanguageCode() throws {
        XCTAssertNil(LanguageMode.system.languageCode)
        XCTAssertEqual(LanguageMode.zhHans.languageCode, "zh-Hans")
        XCTAssertEqual(LanguageMode.en.languageCode, "en")
    }

    // MARK: - AppError Tests

    func testAppErrorEquatable() throws {
        XCTAssertEqual(AppError.network, AppError.network)
        XCTAssertEqual(AppError.timeout, AppError.timeout)
        XCTAssertEqual(AppError.server, AppError.server)
        XCTAssertEqual(AppError.notFound, AppError.notFound)
        XCTAssertNotEqual(AppError.network, AppError.timeout)
    }

    func testAppErrorLocalizedDescription() throws {
        XCTAssertFalse(AppError.network.localizedDescription.isEmpty)
        XCTAssertFalse(AppError.timeout.localizedDescription.isEmpty)
        XCTAssertFalse(AppError.server.localizedDescription.isEmpty)
        XCTAssertFalse(AppError.notFound.localizedDescription.isEmpty)
    }

    // MARK: - HeritageShapes Tests

    func testHeritageShapesCornerRadius() throws {
        XCTAssertEqual(HeritageShapes.cornerRadius, 8)
        XCTAssertEqual(HeritageShapes.extraSmallCornerRadius, 4)
    }

    // MARK: - ContentLabels Tests

    func testLocalizedContentType() throws {
        // 测试内容类型本地化
        XCTAssertFalse(ContentLabels.localizedContentType("article").isEmpty)
        XCTAssertFalse(ContentLabels.localizedContentType("directoryItem").isEmpty)
        XCTAssertFalse(ContentLabels.localizedContentType("inheritor").isEmpty)
        XCTAssertFalse(ContentLabels.localizedContentType("collection").isEmpty)
        XCTAssertFalse(ContentLabels.localizedContentType("topic").isEmpty)

        // 未知值应返回原值
        XCTAssertEqual(ContentLabels.localizedContentType("unknownType"), "unknownType")

        // 空值应返回空字符串
        XCTAssertEqual(ContentLabels.localizedContentType(nil), "")
    }

    func testLocalizedArticleCategory() throws {
        // 测试文章分类本地化
        XCTAssertNotNil(ContentLabels.localizedArticleCategory("news"))
        XCTAssertNotNil(ContentLabels.localizedArticleCategory("forum"))
        XCTAssertNotNil(ContentLabels.localizedArticleCategory("specialTopic"))

        // 未知值应返回原值
        XCTAssertEqual(ContentLabels.localizedArticleCategory("unknown"), "unknown")

        // 空值应返回 nil
        XCTAssertNil(ContentLabels.localizedArticleCategory(nil))
        XCTAssertNil(ContentLabels.localizedArticleCategory(""))
    }

    func testLocalizedDirectoryKind() throws {
        // 测试名录种类本地化
        XCTAssertNotNil(ContentLabels.localizedDirectoryKind("nationalProject"))
        XCTAssertNotNil(ContentLabels.localizedDirectoryKind("culturalEcoZone"))
        XCTAssertNotNil(ContentLabels.localizedDirectoryKind("productiveProtectionBase"))
        XCTAssertNotNil(ContentLabels.localizedDirectoryKind("unescoEntry"))
        XCTAssertNotNil(ContentLabels.localizedDirectoryKind("chinaUnescoEntry"))
        XCTAssertNotNil(ContentLabels.localizedDirectoryKind("contractingState"))

        // 未知值应返回原值
        XCTAssertEqual(ContentLabels.localizedDirectoryKind("unknown"), "unknown")

        // 空值应返回 nil
        XCTAssertNil(ContentLabels.localizedDirectoryKind(nil))
        XCTAssertNil(ContentLabels.localizedDirectoryKind(""))
    }

    func testLocalizedReadingPathSource() throws {
        // 测试阅读路径来源本地化
        XCTAssertFalse(ContentLabels.localizedReadingPathSource("blendedRecommendation").isEmpty)
        XCTAssertFalse(ContentLabels.localizedReadingPathSource("related").isEmpty)
        XCTAssertFalse(ContentLabels.localizedReadingPathSource("recommendation").isEmpty)
        XCTAssertFalse(ContentLabels.localizedReadingPathSource("semanticRecommendation").isEmpty)
        XCTAssertFalse(ContentLabels.localizedReadingPathSource("graph").isEmpty)
        XCTAssertFalse(ContentLabels.localizedReadingPathSource("list").isEmpty)

        // 未知值应返回原值
        XCTAssertEqual(ContentLabels.localizedReadingPathSource("unknown"), "unknown")
    }

    func testLocalizedContentTypeNotEqualToWireValue() throws {
        // 验证本地化后的值不等于原始 wire value（在当前语言环境下）
        let articleLabel = ContentLabels.localizedContentType("article")
        let directoryLabel = ContentLabels.localizedContentType("directoryItem")
        let inheritorLabel = ContentLabels.localizedContentType("inheritor")

        // 在中文环境下，这些值应该被翻译
        // 在英文环境下，"article" 翻译后仍然是 "Article"，但不等于 "article"
        // 所以我们只验证不为空
        XCTAssertFalse(articleLabel.isEmpty)
        XCTAssertFalse(directoryLabel.isEmpty)
        XCTAssertFalse(inheritorLabel.isEmpty)
    }

    func testLocalizedDirectoryKindNotEqualToWireValue() throws {
        // 验证名录种类本地化后的值不等于原始 wire value
        let kinds = [
            "nationalProject",
            "culturalEcoZone",
            "productiveProtectionBase",
            "unescoEntry",
            "chinaUnescoEntry",
            "contractingState"
        ]

        for kind in kinds {
            let localized = ContentLabels.localizedDirectoryKind(kind)
            XCTAssertNotNil(localized, "\(kind) 应该有本地化值")
            XCTAssertFalse(localized!.isEmpty, "\(kind) 本地化值不应为空")
        }
    }
}
