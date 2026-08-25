#if os(iOS)
import SwiftUI

/// A floating tab bar for iOS 16–25 (which have no native Liquid Glass). It is
/// tuned to match the iOS 26 system tab bar 1:1: a near-full-width frosted
/// capsule, filled primary-colour icons, an accent-tinted selected item, and a
/// **subtle lighter-glass pill** that slides behind the active tab
/// (matchedGeometryEffect) — understated, the way the real one is.
struct GlassTabBar: View {
    struct Item: Identifiable {
        let tab: IOSTab
        let title: LocalizedStringKey
        let icon: String
        var id: IOSTab { tab }
    }

    let items: [Item]
    @Binding var selection: IOSTab
    var onReselect: (IOSTab) -> Void = { _ in }

    @Namespace private var pillNamespace
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background { Capsule().fill(.regularMaterial) }
        .overlay {
            Capsule().strokeBorder(.white.opacity(colorScheme == .dark ? 0.10 : 0.35),
                                   lineWidth: 0.5)
        }
        .clipShape(Capsule())
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.30 : 0.12), radius: 14, y: 5)
        .padding(.horizontal, 14)
        .animation(.spring(response: 0.34, dampingFraction: 0.78), value: selection)
    }

    private func tabButton(_ item: GlassTabBar.Item) -> some View {
        let isSelected = selection == item.tab
        return Button {
            if isSelected { onReselect(item.tab) } else { selection = item.tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: item.icon)
                    .font(.system(size: 21, weight: .semibold))
                    .symbolVariant(.fill)
                Text(item.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(.primary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    selectionPill
                        .matchedGeometryEffect(id: "activePill", in: pillNamespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// The sliding selection indicator — a subtle lighter-glass pill, hugging
    /// the content with a gap to its neighbours, matching the low-contrast
    /// highlight the native iOS 26 bar draws behind the selected tab.
    private var selectionPill: some View {
        let isDark = colorScheme == .dark
        return RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.white.opacity(isDark ? 0.13 : 0.55))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(.white.opacity(isDark ? 0.14 : 0.5), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(isDark ? 0.18 : 0.06), radius: 3, y: 1)
            .padding(.horizontal, 8)
    }
}
#endif
