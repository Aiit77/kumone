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
    func testImmersiveModeRemovesTopLyricsFloatingButton() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTestingDemoTrack",
            "-uiTestingIOS15Root",
            "-uiTestingNowPlaying",
            "-uiTestingImmersiveNowPlaying"
        ]
        app.launch()

        XCTAssertTrue(
            app.buttons["immersiveFavoriteButton"].waitForExistence(timeout: 8),
            "沉浸模式应继续显示收藏心形按钮"
        )
        XCTAssertFalse(
            app.buttons["immersiveLyricsFloatingButton"].exists,
            "沉浸模式右上角不应再显示浮窗歌词按钮"
        )
    }

    @MainActor
    func testImmersiveMoreMenuAdvancesToNextTrack() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTestingDemoTrack",
            "-uiTestingIOS15Root",
            "-uiTestingNowPlaying",
            "-uiTestingImmersiveNowPlaying"
        ]
        app.launch()

        XCTAssertTrue(
            app.staticTexts["UI Test Track"].waitForExistence(timeout: 8),
            "测试应从确定的第一首演示曲目开始"
        )
        let moreMenu = app.buttons["immersiveMoreMenu"]
        XCTAssertTrue(moreMenu.waitForExistence(timeout: 8))
        moreMenu.tap()

        let nextAction = app.buttons["下一曲播放"]
        XCTAssertTrue(
            nextAction.waitForExistence(timeout: 4),
            "三点菜单应显示可点击的下一曲动作"
        )
        nextAction.tap()

        XCTAssertTrue(
            app.staticTexts["UI Test Next Track"].waitForExistence(timeout: 5),
            "点击下一曲动作后应立即切换到队列中的下一首"
        )
        XCTAssertFalse(
            nextAction.exists,
            "完成下一曲动作后系统操作菜单应自动收回"
        )
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

        let closeButton = app.buttons["nowPlayingCloseButton"]
        let lyricsButton = app.buttons["classicLyricsFloatingButton"]
        XCTAssertTrue(
            closeButton.waitForExistence(timeout: 8),
            "经典模式应继续显示原有左上角关闭控件"
        )
        XCTAssertTrue(
            lyricsButton.waitForExistence(timeout: 8),
            "经典模式右上角应提供歌词浮窗按钮"
        )
        XCTAssertEqual(
            closeButton.frame.midY,
            lyricsButton.frame.midY,
            accuracy: 1,
            "经典模式歌词按钮应与左上关闭按钮处于同一高度"
        )
        XCTAssertEqual(closeButton.frame.size, lyricsButton.frame.size)
        XCTAssertFalse(
            app.buttons["nowPlayingPosterCloseButton"].exists,
            "沉浸模式专用右上角关闭按钮不应出现在经典模式"
        )
    }
}
