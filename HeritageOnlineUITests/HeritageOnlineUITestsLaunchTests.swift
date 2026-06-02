import XCTest

final class HeritageOnlineUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 插入测试代码来验证启动后的状态
        // 例如：验证特定 UI 元素存在
    }
}
