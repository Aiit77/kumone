#if os(iOS)
import SwiftUI
import UIKit

/// iOS 15 回退根容器。避免 NavigationStack、NavigationPath 与新式 Tab API，
/// 同时维持音乐浏览、播放、设置、登录和更新检查等核心能力。
public struct IOS15MainWindow: View {
    @StateObject private var player = PlayerService.shared
    @StateObject private var account = AccountStore.shared
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var toasts = ToastCenter.shared
    @StateObject private var updater = IOSUpdater.shared
    @StateObject private var keyboard = IOS15KeyboardState()
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedTab = 0
    @State private var showLogin = false
    @State private var showSettings = false

    public init() {}

    public var body: some View {
        tabContent
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomChrome
            }
            // 只由 IOS15KeyboardState 处理当次应用内键盘帧，避免从其他 App
            // 返回时 SwiftUI 继续沿用过期 keyboard-safe-area 导致播放器悬浮错位。
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .environmentObject(player)
            .environmentObject(account)
            .environmentObject(settings)
            .environmentObject(toasts)
            .tint(Theme.accent)
            .preferredColorScheme(settings.appearance.colorScheme)
            .environment(\.openLogin, { showLogin = true })
            .task {
                await account.bootstrap()
                IOSUpdater.shared.check(interactive: false)
            }
            .onChange(of: scenePhase) { phase in
                guard phase == .active else { return }
                keyboard.resetForSceneActivation()
                DispatchQueue.main.async {
                    IOS15KeyboardDismissal.dismiss()
                    keyboard.resetForSceneActivation()
                }
            }
            .onChange(of: player.showNowPlaying) { isPresented in
                if isPresented {
                    IOS15KeyboardDismissal.dismiss()
                    keyboard.resetForSceneActivation()
                }
            }
            .fullScreenCover(isPresented: $player.showNowPlaying) {
                IOSNowPlayingPresentation(
                    isPresented: $player.showNowPlaying,
                    mode: settings.nowPlayingMode,
                    usesSystemInteractiveDismissal: true,
                    dismissAnimation: nil
                ) {
                    NowPlayingView()
                        .environmentObject(player)
                        .environmentObject(account)
                        .environmentObject(settings)
                }
            }
            .sheet(isPresented: $updater.showSheet, onDismiss: dismissKeyboardAndResetLayout) {
                IOSUpdaterSheet()
            }
            .sheet(isPresented: $showLogin, onDismiss: dismissKeyboardAndResetLayout) {
                LoginSheet()
                    .environmentObject(account)
                    .environmentObject(toasts)
            }
            .sheet(isPresented: $showSettings, onDismiss: dismissKeyboardAndResetLayout) {
                NavigationView {
                    SettingsView()
                        .navigationTitle("设置")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("完成") { showSettings = false }
                            }
                        }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .overlay(alignment: .top) {
                if let toast = toasts.current {
                    ToastView(toast: toast)
                        .padding(.top, 8)
                }
            }
    }

    /// 不使用 TabView，避免系统底栏和自定义胶囊标签重复叠加。
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            legacyNavigation { HomeView() }
        case 1:
            legacyNavigation { IOS15ExplorePlaceholder() }
        case 2:
            legacyNavigation { FMView() }
        case 3:
            legacyNavigation { SearchView(query: "") }
        default:
            legacyNavigation { IOS15LibraryView(showLogin: $showLogin, showSettings: $showSettings) }
        }
    }

    private var bottomChrome: some View {
        VStack(spacing: 8) {
            if player.hasCurrentTrack {
                IOS15MiniPlayerBar()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            IOS15CapsuleTabBar(items: Self.tabItems, selection: $selectedTab)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 6)
        // 有效键盘出现时把播放控件整体上移；回到前台时状态会先归零，
        // 因而不会再被外部 App 遗留的键盘 frame 顶起。
        .padding(.bottom, keyboard.overlap)
        .animation(AppAnimation.standard, value: player.hasCurrentTrack)
        .animation(AppAnimation.quick, value: keyboard.overlap)
    }

    private func dismissKeyboardAndResetLayout() {
        IOS15KeyboardDismissal.dismiss()
        keyboard.resetForSceneActivation()
    }

    @ViewBuilder
    private func legacyNavigation<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private static let tabItems: [IOS15CapsuleTabBar.Item] = [
        .init(id: 0, title: "推荐", icon: "house"),
        .init(id: 1, title: "精选", icon: "square.grid.2x2"),
        .init(id: 2, title: "漫游", icon: "dot.radiowaves.left.and.right"),
        .init(id: 3, title: "搜索", icon: "magnifyingglass"),
        .init(id: 4, title: "我的", icon: "person.crop.circle"),
    ]
}

private struct IOS15MiniPlayerBar: View {
    @EnvironmentObject private var player: PlayerService

    var body: some View {
        HStack(spacing: 6) {
            Button { player.showNowPlaying = true } label: {
                HStack(spacing: 9) {
                    CachedAsyncImage(url: player.currentTrack?.album.picUrl?.resizedImageURL(96), animated: false)
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .strokeBorder(.white.opacity(0.22), lineWidth: 0.5)
                        }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.currentTrack?.name ?? "")
                            .font(.system(size: 13, weight: .bold))
                            .lineLimit(1)
                        Text(player.currentTrack?.artistNames ?? "")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("打开正在播放")

            Button(action: player.cyclePlaybackRate) {
                Text(player.playbackRate.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Theme.accent)
                    .frame(minWidth: 42, minHeight: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.pressable)
            .accessibilityLabel("倍速播放，当前 \(player.playbackRate.displayName)")

            Button(action: player.togglePlayPause) {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 17, weight: .bold))
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.pressable)
            .accessibilityLabel(player.isPlaying ? "暂停" : "播放")

            Button(action: player.next) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 38, height: 38)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.pressable)
            .accessibilityLabel("下一首")
        }
        .padding(.leading, 10)
        .padding(.trailing, 6)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
    }
}

private struct IOS15ExplorePlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.accent)
            Text("精选")
                .font(.title2.weight(.bold))
            Text("iOS 15 兼容模式保留了推荐、搜索、播放和个人设置；更多精选导航可在较新系统中使用。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("精选")
    }
}

private struct IOS15LibraryView: View {
    @Binding var showLogin: Bool
    @Binding var showSettings: Bool
    @EnvironmentObject private var account: AccountStore

    var body: some View {
        List {
            Section {
                if let profile = account.profile {
                    HStack(spacing: 12) {
                        CachedAsyncImage(url: profile.avatarUrl?.resizedImageURL(96), animated: false)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                        Text(profile.nickname).font(.headline)
                    }
                } else {
                    Button { showLogin = true } label: {
                        Label("登录网易云音乐", systemImage: "person.crop.circle.badge.plus")
                    }
                }
            }

            if account.hasAuthCookie {
                Section("我的音乐") {
                    Text("已登录，可在推荐、精选和搜索中浏览并播放音乐。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button { showSettings = true } label: {
                    Label("设置", systemImage: "gearshape")
                }
            }
        }
        .navigationTitle("我的")
    }
}

private enum IOS15KeyboardDismissal {
    static func dismiss() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
#endif
