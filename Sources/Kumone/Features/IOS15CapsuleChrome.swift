#if os(iOS)
import SwiftUI
import UIKit

/// iOS 15 专用的底部悬浮胶囊标签栏。
///
/// 该实现只使用普通 Button，避免使用横向拖拽手势抢占页面列表的滚动。
struct IOS15CapsuleTabBar: View {
    struct Item: Identifiable {
        let id: Int
        let title: LocalizedStringKey
        let icon: String
    }

    let items: [Item]
    @Binding var selection: Int

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let contentHeight: CGFloat = 56
    private let innerInset: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            let count = max(items.count, 1)
            let itemWidth = proxy.size.width / CGFloat(count)
            let selectedIndex = items.firstIndex { $0.id == selection } ?? 0

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(selectionFill)
                    .frame(width: max(0, itemWidth - innerInset * 2), height: contentHeight)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(selectionRim, lineWidth: 0.7)
                            .overlay(alignment: .top) {
                                Capsule(style: .continuous)
                                    .strokeBorder(.white.opacity(colorScheme == .dark ? 0.14 : 0.48), lineWidth: 0.5)
                                    .mask(
                                        Rectangle()
                                            .frame(height: contentHeight * 0.42)
                                            .frame(maxHeight: .infinity, alignment: .top)
                                    )
                            }
                    }
                    .shadow(
                        color: Theme.accent.opacity(colorScheme == .dark ? 0.30 : 0.18),
                        radius: colorScheme == .dark ? 8 : 6,
                        y: 3
                    )
                    .offset(x: CGFloat(selectedIndex) * itemWidth + innerInset)
                    .animation(selectionAnimation, value: selection)

                HStack(spacing: 0) {
                    ForEach(items) { item in
                        Button {
                            select(item.id)
                        } label: {
                            label(for: item)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(IOS15CapsuleButtonStyle())
                        .accessibilityLabel(item.title)
                        .accessibilityAddTraits(selection == item.id ? .isSelected : [])
                    }
                }
            }
        }
        .frame(height: contentHeight)
        .padding(innerInset)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(containerRim, lineWidth: colorScheme == .dark ? 0.9 : 0.6)
        }
        .clipShape(Capsule(style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.34 : 0.12), radius: 14, y: 5)
    }

    private func label(for item: Item) -> some View {
        let isSelected = selection == item.id
        return VStack(spacing: 3) {
            Image(systemName: item.icon)
                .font(.system(size: 20, weight: .bold))
                .symbolVariant(.fill)
            Text(item.title)
                .font(.system(size: 10, weight: .bold))
                .lineLimit(1)
        }
        .foregroundStyle(isSelected ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(unselectedForeground))
    }

    private func select(_ item: Int) {
        guard selection != item else { return }
        IOS15SelectionFeedback.perform()
        withAnimation(selectionAnimation) {
            selection = item
        }
    }

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.82)
    }

    private var selectionFill: Color {
        Theme.accent.opacity(colorScheme == .dark ? 0.36 : 0.16)
    }

    private var selectionRim: Color {
        Theme.accent.opacity(colorScheme == .dark ? 0.80 : 0.50)
    }

    private var containerRim: Color {
        .white.opacity(colorScheme == .dark ? 0.28 : 0.52)
    }

    private var unselectedForeground: Color {
        .primary.opacity(colorScheme == .dark ? 0.90 : 0.64)
    }
}

/// 等宽的胶囊式筛选控件，用于替换 iOS 15 上不可定制的系统分段控件。
struct IOS15CapsuleSegmentedControl: View {
    struct Segment: Identifiable {
        let id: Int
        let title: LocalizedStringKey
        let icon: String?
    }

    let segments: [Segment]
    @Binding var selection: Int

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let height: CGFloat = 42
    private let inset: CGFloat = 3

    var body: some View {
        GeometryReader { proxy in
            let count = max(segments.count, 1)
            let width = proxy.size.width / CGFloat(count)
            let selectedIndex = segments.firstIndex { $0.id == selection } ?? 0

            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Theme.accent.opacity(colorScheme == .dark ? 0.30 : 0.14))
                    .frame(width: max(0, width - inset * 2), height: height)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Theme.accent.opacity(colorScheme == .dark ? 0.72 : 0.40), lineWidth: 0.6)
                    }
                    .shadow(color: Theme.accent.opacity(colorScheme == .dark ? 0.24 : 0.13), radius: 5, y: 2)
                    .offset(x: CGFloat(selectedIndex) * width + inset)
                    .animation(selectionAnimation, value: selection)

                HStack(spacing: 0) {
                    ForEach(segments) { segment in
                        Button {
                            select(segment.id)
                        } label: {
                            HStack(spacing: 5) {
                                if let icon = segment.icon {
                                    Image(systemName: icon)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                Text(segment.title)
                                    .font(.system(size: 14, weight: .bold))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(Rectangle())
                            .foregroundStyle(
                                selection == segment.id
                                    ? AnyShapeStyle(Theme.accent)
                                    : AnyShapeStyle(.primary.opacity(colorScheme == .dark ? 0.88 : 0.68))
                            )
                        }
                        .buttonStyle(IOS15CapsuleButtonStyle())
                        .accessibilityAddTraits(selection == segment.id ? .isSelected : [])
                    }
                }
            }
        }
        .frame(height: height)
        .padding(inset)
        .background(.ultraThinMaterial, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(.white.opacity(colorScheme == .dark ? 0.24 : 0.55), lineWidth: 0.6)
        }
        .clipShape(Capsule(style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 8, y: 3)
    }

    private func select(_ id: Int) {
        guard selection != id else { return }
        IOS15SelectionFeedback.perform()
        withAnimation(selectionAnimation) {
            selection = id
        }
    }

    private var selectionAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.84)
    }
}

private struct IOS15CapsuleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.80 : 1)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

enum IOS15SelectionFeedback {
    static func perform() {
        let feedback = UISelectionFeedbackGenerator()
        feedback.prepare()
        feedback.selectionChanged()
    }
}

/// 防止从其他应用返回时过期的键盘帧继续参与 SwiftUI 布局。
final class IOS15KeyboardState: ObservableObject {
    @Published private(set) var overlap: CGFloat = 0

    private var observers: [NSObjectProtocol] = []

    init(notificationCenter: NotificationCenter = .default) {
        observers = [
            notificationCenter.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.update(from: notification)
            },
            notificationCenter.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.reset()
            }
        ]
    }

    deinit {
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    /// 应用恢复前台时先清空旧状态；属于本应用的新键盘会在下一条系统通知中重新写入。
    func resetForSceneActivation() {
        reset()
        DispatchQueue.main.async { [weak self] in
            self?.reset()
        }
    }

    private func update(from notification: Notification) {
        guard UIApplication.shared.applicationState == .active,
              let window = activeWindow,
              let endFrameValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            reset()
            return
        }

        let endFrame = window.convert(endFrameValue.cgRectValue, from: nil)
        let newOverlap = max(0, window.bounds.maxY - endFrame.minY)
        overlap = min(newOverlap, window.bounds.height)
    }

    private func reset() {
        overlap = 0
    }

    private var activeWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .windows
            .first(where: \.isKeyWindow)
    }
}
#endif
