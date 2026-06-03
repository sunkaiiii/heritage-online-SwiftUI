import XCTest
@testable import HeritageOnline

/// YearFilterValidator 单元测试
/// 覆盖：空字符串、合法年份、非法年份
final class YearFilterValidatorTests: XCTestCase {

    // MARK: - isValidYear

    func testEmptyStringIsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear(""))
    }

    func testWhitespaceOnlyIsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("   "))
    }

    func testValidYear2024() {
        XCTAssertTrue(YearFilterValidator.isValidYear("2024"))
    }

    func testValidYear1000() {
        XCTAssertTrue(YearFilterValidator.isValidYear("1000"))
    }

    func testValidYear2999() {
        XCTAssertTrue(YearFilterValidator.isValidYear("2999"))
    }

    func testNonNumericIsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("20ab"))
    }

    func testThreeDigitsIsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("123"))
    }

    func testFiveDigitsIsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("12345"))
    }

    func testYear0000IsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("0000"))
    }

    func testYear9999IsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("9999"))
    }

    func testYear999IsNotValid() {
        XCTAssertFalse(YearFilterValidator.isValidYear("999"))
    }

    func testYearWithLeadingSpaceIsValid() {
        XCTAssertTrue(YearFilterValidator.isValidYear(" 2024"))
    }

    func testYearWithTrailingSpaceIsValid() {
        XCTAssertTrue(YearFilterValidator.isValidYear("2024 "))
    }

    // MARK: - parseInt

    func testParseEmptyStringReturnsNil() {
        XCTAssertNil(YearFilterValidator.parseInt(""))
    }

    func testParseWhitespaceReturnsNil() {
        XCTAssertNil(YearFilterValidator.parseInt("   "))
    }

    func testParseValidYear() {
        XCTAssertEqual(YearFilterValidator.parseInt("2024"), 2024)
    }

    func testParseInvalidYearReturnsNil() {
        XCTAssertNil(YearFilterValidator.parseInt("20ab"))
    }

    func testParseYearOutOfRangeReturnsNil() {
        XCTAssertNil(YearFilterValidator.parseInt("0000"))
        XCTAssertNil(YearFilterValidator.parseInt("9999"))
    }

    func testParseYearWithSpaces() {
        XCTAssertEqual(YearFilterValidator.parseInt(" 2024 "), 2024)
    }
}
