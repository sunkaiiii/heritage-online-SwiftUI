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
}
