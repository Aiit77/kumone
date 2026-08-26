#if os(iOS)
import SwiftUI
import UIKit

/// iOS 15 回退根容器。避免 NavigationStack、NavigationPath 与新式 Tab API，
/// 同时让播放器和胶囊导航共用稳定的底部安全区。
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
            // 仅使用当前 App 实际收到的键盘帧，避免从其他 App 返回后保留旧布局。
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .environmentObject(player)
            .environmentObject(account)
            .environmentObject(settings)
            .environmentObject(toasts)
            .tint(Theme.accent)
            .preferredColorScheme(settings.appearance.colorScheme)
            .environment(\.openLogin, { showLogin = true })
            .task {
                player.loadUITestDemoTrackIfNeeded()
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
                        // iOS 15 的独立 sheet 不依赖环境对象的隐式继承。
                        // 显式注入可避免 SettingsView 首次绘制时触发 SwiftUI 陷阱。
                        .environmentObject(settings)
                        .environmentObject(account)
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
            legacyNavigation { IOS15ExploreView() }
        case 2:
            legacyNavigation { FMView() }
        case 3:
            // 保持 v0.3.7 搜索结构；其目的地式 NavigationLink 可在 iOS 15 使用。
            legacyNavigation { SearchView(query: "") }
        default:
            legacyNavigation { IOS15CardLibraryView(showLogin: $showLogin, showSettings: $showSettings) }
        }
    }

    private var bottomChrome: some View {
        VStack(spacing: 8) {
            if player.hasCurrentTrack || isUITestingDemoPlayer {
                IOS15MiniPlayerBar()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            IOS15CapsuleTabBar(items: Self.tabItems, selection: $selectedTab)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .padding(.bottom, keyboard.overlap)
        .animation(AppAnimation.standard, value: player.hasCurrentTrack)
        .animation(AppAnimation.quick, value: keyboard.overlap)
    }

    private var isUITestingDemoPlayer: Bool {
        ProcessInfo.processInfo.arguments.contains("-uiTestingDemoTrack")
    }

    private func dismissKeyboardAndResetLayout() {
        IOS15KeyboardDismissal.dismiss()
        keyboard.resetForSceneActivation()
    }

    @ViewBuilder
    private func legacyNavigation<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationView {
            content()
                .background(IOS15DisableInteractivePopGesture())
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

/// 手机宽度将常用控件压缩为一行，宽屏在同一安全区内展示完整的横向控制分区。
private struct IOS15MiniPlayerBar: View {
    @EnvironmentObject private var player: PlayerService

    var body: some View {
        GeometryReader { proxy in
            Group {
                if proxy.size.width >= 620 {
                    wideContent
                } else {
                    compactContent
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .frame(height: 74)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.regularMaterial, in: Capsule(style: .continuous))
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        .accessibilityIdentifier("ios15MiniPlayer")
    }

    private var compactContent: some View {
        VStack(spacing: 1) {
            HStack(spacing: 4) {
                trackSummary
                playbackRateButton
                playPauseButton
                nextButton
                moreMenu
            }
            IOS15MiniPlayerProgress()
                .padding(.leading, 48)
                .padding(.trailing, 8)
        }
    }

    private var wideContent: some View {
        HStack(spacing: 14) {
            trackSummary
                .frame(maxWidth: 250)
            IOS15MiniPlayerProgress()
                .frame(maxWidth: .infinity)
            HStack(spacing: 2) {
                playbackRateButton
                previousButton
                playPauseButton
                nextButton
                moreMenu
            }
        }
    }

    private var trackSummary: some View {
        Button {
            player.showNowPlaying = true
        } label: {
            HStack(spacing: 9) {
                CachedAsyncImage(url: player.currentTrack?.album.picUrl?.resizedImageURL(96), animated: false)
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(.white.opacity(0.22), lineWidth: 0.5)
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text(player.currentTrack?.name ?? "")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(player.currentTrack?.artistNames ?? "")
                        .font(.system(size: 10.5))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("打开正在播放")
        .accessibilityIdentifier("miniPlayerTrackSummary")
    }

    private var playbackRateButton: some View {
        Button(action: player.cyclePlaybackRate) {
            Text(player.playbackRate.displayName)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accent)
                .frame(minWidth: 54, minHeight: 42)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("倍速播放")
        .accessibilityValue(player.playbackRate.displayName)
        .accessibilityIdentifier("miniPlayerPlaybackRateButton")
    }

    private var previousButton: some View {
        Button(action: player.previous) {
            Image(systemName: "backward.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(player.isFMMode ? Color.secondary.opacity(0.35) : Color.secondary)
                .frame(width: 38, height: 42)
        }
        .buttonStyle(.pressable)
        .disabled(player.isFMMode)
        .accessibilityLabel("上一首")
        .accessibilityIdentifier("miniPlayerPreviousButton")
    }

    private var playPauseButton: some View {
        Button(action: player.togglePlayPause) {
            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 42)
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel(player.isPlaying ? "暂停" : "播放")
        .accessibilityIdentifier("miniPlayerPlayPauseButton")
    }

    private var nextButton: some View {
        Button(action: player.next) {
            Image(systemName: "forward.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 38, height: 42)
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("下一首")
        .accessibilityIdentifier("miniPlayerNextButton")
    }

    private var moreMenu: some View {
        Menu {
            Button(action: player.previous) {
                Label("上一首", systemImage: "backward.fill")
            }
            .disabled(player.isFMMode)

            Menu {
                Button {
                    if player.shuffleEnabled { player.toggleShuffle() }
                    player.repeatMode = .off
                } label: {
                    Label("顺序播放", systemImage: "text.line.first.and.arrowtriangle.forward")
                }
                Button {
                    if !player.shuffleEnabled { player.toggleShuffle() }
                    player.repeatMode = .off
                } label: {
                    Label("随机播放", systemImage: "shuffle")
                }
                Button {
                    if player.shuffleEnabled { player.toggleShuffle() }
                    player.repeatMode = .all
                } label: {
                    Label("列表循环", systemImage: "repeat")
                }
                Button {
                    if player.shuffleEnabled { player.toggleShuffle() }
                    player.repeatMode = .one
                } label: {
                    Label("单曲循环", systemImage: "repeat.1")
                }
            } label: {
                Label("播放模式", systemImage: player.repeatMode == .one ? "repeat.1" : "repeat")
            }

            Button {
                player.presentNowPlaying(startingWith: .lyrics)
            } label: {
                Label("歌词", systemImage: "quote.bubble")
            }

            Button {
                player.presentNowPlaying(startingWith: .queue)
            } label: {
                Label("播放队列", systemImage: "list.bullet")
            }

            Button(action: player.toggleMute) {
                Label(player.isMuted ? "取消静音" : "静音", systemImage: player.isMuted ? "speaker.slash" : "speaker.wave.2")
            }

            Divider()

            Button(role: .destructive, action: player.closeCurrentTrack) {
                Label("关闭播放器", systemImage: "xmark.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 38, height: 42)
                .contentShape(Rectangle())
        }
        .buttonStyle(.pressable)
        .accessibilityLabel("更多控制")
        .accessibilityIdentifier("miniPlayerMoreMenu")
    }
}

private struct IOS15MiniPlayerProgress: View {
    @EnvironmentObject private var player: PlayerService

    var body: some View {
        Slider(
            value: Binding(
                get: { min(max(player.progress, 0), max(player.duration, 1)) },
                set: { player.seek(to: $0) }
            ),
            in: 0...max(player.duration, 1)
        )
        .tint(Theme.accent)
        .controlSize(.small)
        .accessibilityLabel("播放进度")
        .accessibilityValue("\(Int(player.progress.rounded())) 秒")
        .accessibilityIdentifier("miniPlayerProgress")
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
