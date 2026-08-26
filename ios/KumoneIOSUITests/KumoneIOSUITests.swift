import XCTest

final class KumoneIOSUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMiniPlayerPlaybackRateCyclesFromOneToOneQuarter() throws {
        let app = XCUIApplication()
        // 通过启动参数注入本地演示曲目，避免测试依赖账户、网络或流媒体解析。
        app.launchArguments = ["-uiTestingDemoTrack", "-uiTestingIOS15Root"]
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

    @MainActor
    func testPosterCloseButtonIsTappable() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTestingDemoTrack",
            "-uiTestingIOS15Root",
            "-uiTestingNowPlaying"
        ]
        app.launch()

        let closeButton = app.buttons["nowPlayingPosterCloseButton"]
        XCTAssertTrue(
            closeButton.waitForExistence(timeout: 8),
            "海报播放页右上角应提供稳定的关闭按钮"
        )
        closeButton.tap()
        XCTAssertFalse(
            closeButton.waitForExistence(timeout: 3),
            "关闭按钮点击后应关闭正在播放页面"
        )
    }
}
