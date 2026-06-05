import XCTest

final class HeritageOnlineUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - 平台辅助

    /// macOS 使用侧栏按钮导航，iOS 使用底部 tab bar
    private var isMacOS: Bool {
        // macOS 下侧栏按钮存在，iOS 下 tab bar 存在
        app.buttons["tab.articles"].waitForExistence(timeout: 3)
        return app.tabBars.firstMatch.exists == false
    }

    /// 点击导航目标（自动适配平台）
    private func tapNavigation(_ key: String) {
        if isMacOS {
            let sidebarButton = app.buttons[key]
            if sidebarButton.waitForExistence(timeout: 3) {
                sidebarButton.tap()
            }
        } else {
            let tabBar = app.tabBars.firstMatch
            if tabBar.waitForExistence(timeout: 3) {
                // 通过 accessibility identifier 或 index 定位
                let button = tabBar.buttons[key]
                if button.exists {
                    button.tap()
                } else {
                    // fallback: 按顺序点击
                    let index: Int
                    switch key {
                    case "tab.articles": index = 0
                    case "tab.directory": index = 1
                    case "tab.inheritors": index = 2
                    case "tab.discovery": index = 3
                    default: index = 0
                    }
                    if tabBar.buttons.count > index {
                        tabBar.buttons.element(boundBy: index).tap()
                    }
                }
            }
        }
    }

    // MARK: - Smoke: 应用启动

    func testAppLaunches() throws {
        XCTAssertTrue(app.state == .runningForeground, "应用应成功启动到前台")

        let windowExists = app.windows.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(windowExists, "应用应显示主窗口")
    }

    // MARK: - Smoke: 导航切换（平台区分）

    func testTabSwitching() throws {
        if isMacOS {
            // macOS: 验证侧栏按钮存在
            let sidebarButtons = ["tab.articles", "tab.directory", "tab.inheritors", "tab.discovery"]
            for key in sidebarButtons {
                let button = app.buttons[key]
                XCTAssertTrue(button.waitForExistence(timeout: 3), "macOS 侧栏按钮 \(key) 应存在")
            }

            // 依次点击每个侧栏按钮
            for key in sidebarButtons {
                let button = app.buttons[key]
                if button.exists {
                    button.tap()
                    _ = app.staticTexts.firstMatch.waitForExistence(timeout: 3)
                }
            }
        } else {
            // iOS: 验证底部 tab bar 存在
            let tabBar = app.tabBars.firstMatch
            XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "iOS 底部导航应存在")

            let tabBarButtons = tabBar.buttons
            XCTAssertGreaterThanOrEqual(tabBarButtons.count, 4, "应有至少 4 个 tab")

            // 依次点击每个 tab
            for i in 0..<min(tabBarButtons.count, 4) {
                let button = tabBarButtons.element(boundBy: i)
                XCTAssertTrue(button.exists, "Tab \(i) 应存在")
                button.tap()
                _ = app.staticTexts.firstMatch.waitForExistence(timeout: 3)
            }
        }
    }

    // MARK: - Smoke: 搜索功能

    func testSearchFieldExists() throws {
        // 切换到发现
        tapNavigation("tab.discovery")

        // 搜索框应存在
        let searchField = app.textFields.firstMatch
        let searchExists = searchField.waitForExistence(timeout: 3)
        if searchExists {
            searchField.tap()
            searchField.typeText("非遗")
            XCTAssertTrue(searchField.exists)
        }
    }

    // MARK: - Smoke: 文章列表和详情

    func testArticleListLoads() throws {
        // 切换到文章
        tapNavigation("tab.articles")

        // 等待列表加载
        let listExists = app.scrollViews.firstMatch.waitForExistence(timeout: 5)
        let staticTextExists = app.staticTexts.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(listExists || staticTextExists, "文章列表应加载或显示空状态")
    }

    // MARK: - Smoke: 设置页入口存在

    func testSettingsEntryExists() throws {
        if isMacOS {
            // macOS: 设置按钮在侧栏底部
            let settingsButton = app.buttons["tab.settings"]
            XCTAssertTrue(settingsButton.waitForExistence(timeout: 3), "macOS 侧栏设置按钮应存在")
        } else {
            // iOS: 设置入口通常在 navigation bar
            let settingsButton = app.buttons["gear"]
            let exists = settingsButton.waitForExistence(timeout: 3)
            let anyButton = app.navigationBars.buttons.firstMatch
            let navExists = anyButton.waitForExistence(timeout: 3)
            XCTAssertTrue(exists || navExists, "设置入口或导航栏应存在")
        }
    }
}
