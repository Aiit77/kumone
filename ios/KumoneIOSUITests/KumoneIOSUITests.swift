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
            "-uiTestingNowPlaying",
            "-uiTestingImmersiveNowPlaying"
        ]
        app.launch()

        let closeButton = app.buttons["nowPlayingPosterCloseButton"]
        XCTAssertTrue(
            closeButton.waitForExistence(timeout: 8),
            "海报播放页右上角应提供稳定的关闭按钮"
        )
        XCTAssertGreaterThanOrEqual(
            closeButton.frame.width,
            64,
            "沉浸模式关闭按钮应提供至少 64pt 的横向触控范围"
        )
        XCTAssertGreaterThanOrEqual(
            closeButton.frame.height,
            64,
            "沉浸模式关闭按钮应提供至少 64pt 的纵向触控范围"
        )
        closeButton.tap()
        XCTAssertFalse(
            closeButton.waitForExistence(timeout: 3),
            "关闭按钮点击后应关闭正在播放页面"
        )
    }

    @MainActor
    func testImmersiveFavoriteAlignsWithLyricsFloatingButton() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTestingDemoTrack",
            "-uiTestingIOS15Root",
            "-uiTestingNowPlaying",
            "-uiTestingImmersiveNowPlaying"
        ]
        app.launch()

        let favorite = app.buttons["immersiveFavoriteButton"]
        let lyrics = app.buttons["immersiveLyricsFloatingButton"]
        XCTAssertTrue(
            favorite.waitForExistence(timeout: 8),
            "沉浸模式应显示收藏心形按钮"
        )
        XCTAssertTrue(
            lyrics.waitForExistence(timeout: 8),
            "沉浸模式应显示歌词浮窗按钮"
        )
        XCTAssertEqual(
            favorite.frame.midY,
            lyrics.frame.midY,
            accuracy: 1,
            "收藏心形与歌词浮窗按钮应处于同一水平基线"
        )
        XCTAssertEqual(favorite.frame.size, lyrics.frame.size)
    }

    @MainActor
    func testClassicModeKeepsOriginalCloseControl() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTestingDemoTrack",
            "-uiTestingIOS15Root",
            "-uiTestingNowPlaying",
            "-uiTestingClassicNowPlaying"
        ]
        app.launch()

        XCTAssertTrue(
            app.buttons["nowPlayingCloseButton"].waitForExistence(timeout: 8),
            "经典模式应继续显示原有左上角关闭控件"
        )
        XCTAssertFalse(
            app.buttons["nowPlayingPosterCloseButton"].exists,
            "沉浸模式专用右上角关闭按钮不应出现在经典模式"
        )
    }
}
