import XCTest
@testable import HeritageOnline

/// ExternalURLValidator 单元测试
/// 覆盖：合法 URL、带空格 URL、非法 scheme、空字符串
final class ExternalURLValidatorTests: XCTestCase {

    func testValidHttpsUrl() {
        let url = ExternalURLValidator.httpURL(from: "https://example.com")
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://example.com")
    }

    func testValidHttpUrl() {
        let url = ExternalURLValidator.httpURL(from: "http://example.com")
        XCTAssertNotNil(url)
    }

    func testUrlWithLeadingTrailingSpaces() {
        let url = ExternalURLValidator.httpURL(from: " https://example.com ")
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://example.com")
    }

    func testUrlWithNewlines() {
        let url = ExternalURLValidator.httpURL(from: "\nhttps://example.com\n")
        XCTAssertNotNil(url)
    }

    func testNilReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: nil))
    }

    func testEmptyStringReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: ""))
    }

    func testWhitespaceOnlyReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: "   "))
    }

    func testRelativePathReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: "/path/to/page"))
    }

    func testFileSchemeReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: "file:///path/to/file"))
    }

    func testJavascriptSchemeReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: "javascript:alert('xss')"))
    }

    func testFtpSchemeReturnsNil() {
        XCTAssertNil(ExternalURLValidator.httpURL(from: "ftp://example.com"))
    }
}
