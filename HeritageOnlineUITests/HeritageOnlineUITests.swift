import XCTest

final class HeritageOnlineUITests: XCTestCase {

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        // 验证应用启动成功
        XCTAssertTrue(app.state == .runningForeground, "应用应成功启动到前台")

        // 验证存在至少一个窗口
        let windowExists = app.windows.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(windowExists, "应用应显示主窗口")
    }
}
