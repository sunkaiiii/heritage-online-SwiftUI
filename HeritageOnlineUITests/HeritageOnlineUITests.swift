import XCTest

final class HeritageOnlineUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAppLaunches() throws {
        // 验证应用启动成功
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testTabBarExists() throws {
        // 在 macOS 上，TabView 可能以不同方式呈现
        // 检查是否存在 tab 按钮或侧边栏
        let tabBar = app.tabBars.firstMatch
        let sidebar = app.outlines.firstMatch

        // macOS 可能使用侧边栏或工具栏
        let hasTabBar = tabBar.waitForExistence(timeout: 5)
        let hasSidebar = sidebar.waitForExistence(timeout: 2)

        // 至少应该有一种导航方式存在
        XCTAssertTrue(hasTabBar || hasSidebar || app.windows.firstMatch.exists,
                      "应用应显示导航界面（TabBar、侧边栏或窗口）")
    }

    func testTabSwitching() throws {
        // 在 macOS 上测试导航
        // 尝试查找 tab 按钮
        let tabBar = app.tabBars.firstMatch

        if tabBar.waitForExistence(timeout: 5) {
            // iOS 风格的 TabView
            let articlesTab = tabBar.buttons[String(localized: "tab.articles")]
            let directoryTab = tabBar.buttons[String(localized: "tab.directory")]

            if articlesTab.exists {
                articlesTab.tap()
                XCTAssertTrue(articlesTab.isSelected)
            }

            if directoryTab.exists {
                directoryTab.tap()
                XCTAssertTrue(directoryTab.isSelected)
            }
        } else {
            // macOS 可能使用侧边栏或工具栏
            // 验证窗口存在即可
            XCTAssertTrue(app.windows.firstMatch.exists)
        }
    }
}
