import XCTest

final class KumoneIOSUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMiniPlayerPlaybackRateCyclesFromOneToOneQuarter() throws {
        let app = XCUIApplication()
        // 通过启动参数注入本地演示曲目，避免测试依赖账户、网络或流媒体解析。
        app.launchArguments = ["-uiTestingDemoTrack"]
        app.launch()

        let rateButton = app.buttons["miniPlayerPlaybackRateButton"]
        XCTAssertTrue(
            rateButton.waitForExistence(timeout: 8),
            "迷你播放器的倍速按钮应具有稳定的自动化标识"
        )
        XCTAssertEqual(rateButton.value as? String, "1×")

        rateButton.tap()
        XCTAssertEqual(rateButton.value as? String, "1.25×")
    }
}
