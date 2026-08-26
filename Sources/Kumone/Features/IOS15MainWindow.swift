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
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedTab = 0
    @State private var showLogin = false
    @State private var showSettings = false

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                legacyNavigation { HomeView() }
                    .tabItem { Label("推荐", systemImage: "house") }
                    .tag(0)
                legacyNavigation { IOS15ExplorePlaceholder() }
                    .tabItem { Label("精选", systemImage: "square.grid.2x2") }
                    .tag(1)
                legacyNavigation { FMView() }
                    .tabItem { Label("漫游", systemImage: "wave.3.right.circle") }
                    .tag(2)
                legacyNavigation { SearchView(query: "") }
                    .tabItem { Label("搜索", systemImage: "magnifyingglass") }
                    .tag(3)
                legacyNavigation { IOS15LibraryView(showLogin: $showLogin, showSettings: $showSettings) }
                    .tabItem { Label("我的", systemImage: "person.crop.circle") }
                    .tag(4)
            }

            if player.hasCurrentTrack {
                IOS15MiniPlayerBar()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 56)
            }
        }
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
            DispatchQueue.main.async { IOS15KeyboardDismissal.dismiss() }
        }
        .onChange(of: player.showNowPlaying) { isPresented in
            if isPresented { IOS15KeyboardDismissal.dismiss() }
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
        .sheet(isPresented: $updater.showSheet, onDismiss: IOS15KeyboardDismissal.dismiss) {
            IOSUpdaterSheet()
        }
        .sheet(isPresented: $showLogin, onDismiss: IOS15KeyboardDismissal.dismiss) {
            LoginSheet()
                .environmentObject(account)
                .environmentObject(toasts)
        }
        .sheet(isPresented: $showSettings, onDismiss: IOS15KeyboardDismissal.dismiss) {
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

    @ViewBuilder
    private func legacyNavigation<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct IOS15MiniPlayerBar: View {
    @EnvironmentObject private var player: PlayerService

    var body: some View {
        HStack(spacing: 10) {
            Button { player.showNowPlaying = true } label: {
                HStack(spacing: 9) {
                    CachedAsyncImage(url: player.currentTrack?.album.picUrl?.resizedImageURL(96), animated: false)
                        .frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.currentTrack?.name ?? "")
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                        Text(player.currentTrack?.artistNames ?? "")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            Button(action: player.togglePlayPause) {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.pressable)
            Button(action: player.next) {
                Image(systemName: "forward.fill")
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.pressable)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: Capsule())
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
