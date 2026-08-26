import SwiftUI

#if os(iOS)
/// Shared presentation metrics retained for the explicit close-button animation.
enum NowPlayingPresentationMetrics {
    // 仅供迷你播放器向上展开使用；不是播放页的下滑关闭手势。
    static let miniPlayerExpandDistance: CGFloat = 28
    static let miniPlayerExpandPrediction: CGFloat = 72

    static let presentationAnimation = Animation.spring(
        response: 0.52,
        dampingFraction: 0.9,
        blendDuration: 0.1
    )

    /// The system can briefly report no accessory placement while it reparents
    /// the view between expanded and inline tab-bar containers. Prefer compact
    /// layout during that undefined interval.
    static func shouldUseInlineMiniPlayerLayout(
        placementIsInline: Bool?
    ) -> Bool {
        placementIsInline ?? true
    }

    static func shouldExpandFromMiniPlayer(
        translation: CGFloat,
        predictedTranslation: CGFloat
    ) -> Bool {
        translation < -miniPlayerExpandDistance
            || predictedTranslation < -miniPlayerExpandPrediction
    }
}

private struct DismissNowPlayingActionKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var dismissNowPlayingAction: (() -> Void)? {
        get { self[DismissNowPlayingActionKey.self] }
        set { self[DismissNowPlayingActionKey.self] = newValue }
    }
}

/// iOS 15 playback presentation with an explicit close button supplied by
/// `NowPlayingView`. No drag indicator, custom downward gesture or interactive
/// swipe dismissal is installed here, matching the v0.3.5 lyrics/poster flow.
struct IOSNowPlayingPresentation<Content: View>: View {
    private let dismissAnimation: Animation?
    private let content: Content

    @Binding private var isPresented: Bool

    init(
        isPresented: Binding<Bool>,
        mode: NowPlayingMode,
        usesSystemInteractiveDismissal: Bool = false,
        dismissAnimation: Animation? = NowPlayingPresentationMetrics.presentationAnimation,
        @ViewBuilder content: () -> Content
    ) {
        _isPresented = isPresented
        // Kept in the initializer for compatibility with the two existing
        // window call sites. The old immersive swipe behavior is deliberately
        // not enabled regardless of these legacy inputs.
        _ = mode
        _ = usesSystemInteractiveDismissal
        self.dismissAnimation = dismissAnimation
        self.content = content()
    }

    var body: some View {
        content
            .environment(\.dismissNowPlayingAction, dismiss)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func dismiss() {
        if let dismissAnimation {
            withAnimation(dismissAnimation) {
                isPresented = false
            }
        } else {
            isPresented = false
        }
    }
}
#endif
