import SwiftUI
import KumoneIOSFeature

@main
struct KumoneIOSApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                IOSMainWindow()
            } else {
                IOS15MainWindow()
            }
        }
    }
}
