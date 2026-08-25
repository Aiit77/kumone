#if os(iOS)
import SwiftUI

/// A floating capsule tab bar. On iOS 26+ it uses the system Liquid Glass;
/// on iOS 16–25 it approximates it (Telegram-style): a blurred material
/// capsule with a bright top-edge highlight, a hairline rim, and a soft
/// drop shadow, so it reads as glass even before the OS supports it.
struct GlassTabBar: View {
    struct Item: Identifiable {
        let tab: IOSTab
        let title: LocalizedStringKey
        let icon: String
        var id: IOSTab { tab }
    }

    let items: [Item]
    @Binding var selection: IOSTab
    /// Re-select the active tab (e.g. pop to root).
    var onReselect: (IOSTab) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background { glassCapsule }
        .clipShape(Capsule())
        .overlay {
            Capsule().strokeBorder(
                LinearGradient(
                    colors: [.white.opacity(0.35), .white.opacity(0.06)],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 0.6
            )
        }
        .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
        .padding(.horizontal, 44)
    }

    private func tabButton(_ item: GlassTabBar.Item) -> some View {
        let isSelected = selection == item.tab
        return Button {
            if isSelected {
                onReselect(item.tab)
            } else {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                    selection = item.tab
                }
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .medium))
                    .symbolVariant(isSelected ? .fill : .none)
                Text(item.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(.secondary))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(Theme.accent.opacity(0.14))
                        .padding(.horizontal, 4)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var glassCapsule: some View {
        if #available(iOS 26.0, *) {
            Color.clear.glassEffect(.regular, in: Capsule())
        } else {
            // Simulated Liquid Glass for iOS 16–25.
            ZStack {
                Capsule().fill(.ultraThinMaterial)
                // Top-edge highlight → fake light refraction.
                LinearGradient(
                    colors: [.white.opacity(0.22), .white.opacity(0.03), .clear],
                    startPoint: .top, endPoint: .center
                )
                .clipShape(Capsule())
                .blendMode(.plusLighter)
            }
        }
    }
}
#endif
