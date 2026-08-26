import SwiftUI
import KumoneIOSFeature

@main
struct KumoneIOSApp: App {
    var body: some Scene {
        WindowGroup {
            Group {
                if #available(iOS 16.0, *) {
                    IOSMainWindow()
                } else {
                    IOS15MainWindow()
                }
            }
            .task {
                PlayerService.shared.loadUITestDemoTrackIfNeeded()
            }
        }
    }
}
