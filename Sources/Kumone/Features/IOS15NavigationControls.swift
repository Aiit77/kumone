#if os(iOS)
import SwiftUI
import UIKit

/// 关闭 iOS 15 NavigationView 的交互式左缘返回手势。
/// 页面仍保留系统导航栏的显式返回按钮，避免用自定义手势抢占滚动视图。
struct IOS15DisableInteractivePopGesture: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GestureControlViewController {
        GestureControlViewController()
    }

    func updateUIViewController(_ uiViewController: GestureControlViewController, context: Context) {
        uiViewController.disableInteractivePopIfAvailable()
    }

    final class GestureControlViewController: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            disableInteractivePopIfAvailable()
        }

        func disableInteractivePopIfAvailable() {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
#endif
