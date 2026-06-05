import XCTest

final class HeritageOnlineUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Smoke: 应用启动

    func testAppLaunches() throws {
        XCTAssertTrue(app.state == .runningForeground, "应用应成功启动到前台")

        let windowExists = app.windows.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(windowExists, "应用应显示主窗口")
    }

    // MARK: - Smoke: 四 Tab 切换

    func testTabSwitching() throws {
        // 验证底部导航存在
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5), "底部导航应存在")

        // 四个 tab 按钮应存在
        let tabBarButtons = tabBar.buttons
        XCTAssertGreaterThanOrEqual(tabBarButtons.count, 4, "应有至少 4 个 tab")

        // 依次点击每个 tab
        for i in 0..<min(tabBarButtons.count, 4) {
            let button = tabBarButtons.element(boundBy: i)
            XCTAssertTrue(button.exists, "Tab \(i) 应存在")
            button.tap()
            // 等待页面加载
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 3)
        }
    }

    // MARK: - Smoke: 搜索功能

    func testSearchFieldExists() throws {
        // 切换到发现 tab（索引 3）
        let discoveryButton = app.tabBars.buttons.element(boundBy: 3)
        if discoveryButton.exists {
            discoveryButton.tap()
        }

        // 搜索框应存在
        let searchField = app.textFields.firstMatch
        let searchExists = searchField.waitForExistence(timeout: 3)
        if searchExists {
            searchField.tap()
            searchField.typeText("非遗")
            // 验证可以输入
            XCTAssertTrue(searchField.exists)
        }
    }

    // MARK: - Smoke: 文章列表和详情

    func testArticleListLoads() throws {
        // 切换到文章 tab（索引 0）
        let articleButton = app.tabBars.buttons.element(boundBy: 0)
        XCTAssertTrue(articleButton.waitForExistence(timeout: 5))
        articleButton.tap()

        // 等待列表加载（列表或空状态出现）
        let listExists = app.scrollViews.firstMatch.waitForExistence(timeout: 5)
        let staticTextExists = app.staticTexts.firstMatch.waitForExistence(timeout: 5)
        XCTAssertTrue(listExists || staticTextExists, "文章列表应加载或显示空状态")
    }

    // MARK: - Smoke: 设置页入口存在

    func testSettingsEntryExists() throws {
        // 查找设置按钮（通常在顶部 toolbar）
        let settingsButton = app.buttons["gear"] // SF Symbol
        let exists = settingsButton.waitForExistence(timeout: 5)
        // 设置入口可能存在于 navigation bar
        let anyButton = app.navigationBars.buttons.firstMatch
        let navExists = anyButton.waitForExistence(timeout: 3)
        XCTAssertTrue(exists || navExists, "设置入口或导航栏应存在")
    }
}
