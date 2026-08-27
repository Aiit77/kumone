#if os(iOS)
import SwiftUI
import UIKit

/// 观察 iOS 15 `NavigationView` 的原生导航栈。
///
/// 此实现只重新启用系统的 `interactivePopGestureRecognizer`，不添加自定义
/// `DragGesture`，因此不会与歌词、列表和横向滚动视图争夺触控。详情页面入栈后
/// 通知根窗口隐藏自定义底部 chrome；系统左缘返回完成后会自动恢复。
struct IOS15NavigationChromeObserver: UIViewControllerRepresentable {
    @Binding var isDetailPresented: Bool

    func makeUIViewController(context: Context) -> NavigationChromeViewController {
        NavigationChromeViewController { isDetailPresented = $0 }
    }

    func updateUIViewController(_ uiViewController: NavigationChromeViewController, context: Context) {
        uiViewController.onNavigationDepthChanged = { isDetailPresented = $0 }
        uiViewController.refreshNavigationChrome()
    }

    final class NavigationChromeViewController: UIViewController {
        var onNavigationDepthChanged: (Bool) -> Void

        init(onNavigationDepthChanged: @escaping (Bool) -> Void) {
            self.onNavigationDepthChanged = onNavigationDepthChanged
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            nil
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            refreshNavigationChrome()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            // 等待 NavigationView 完成 push，读取最终栈深度而不是过渡前的值。
            DispatchQueue.main.async { [weak self] in
                self?.refreshNavigationChrome()
            }
        }

        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            refreshNavigationChrome()
        }

        func refreshNavigationChrome() {
            guard let navigationController else {
                onNavigationDepthChanged(false)
                return
            }

            let isDetail = navigationController.viewControllers.count > 1
            // 仅恢复 UIKit 自带的左缘返回。系统会在根页自动拒绝该手势。
            navigationController.interactivePopGestureRecognizer?.isEnabled = isDetail
            onNavigationDepthChanged(isDetail)
        }
    }
}
#endif
