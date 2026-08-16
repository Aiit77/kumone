import SwiftUI

struct MainWindow: View {
    @Environment(PlayerService.self) private var player
    @Environment(AccountStore.self) private var account
    @Environment(ToastCenter.self) private var toasts

    @State private var selection: SidebarItem = .home
    @State private var path = NavigationPath()
    @State private var showLogin = false
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection, showLogin: $showLogin)
                .navigationSplitViewColumnWidth(min: 200, ideal: Theme.Layout.sidebarWidth, max: 280)
        } detail: {
            detailStack
        }
        // Immersive now-playing page: hide the whole window toolbar
        // (sidebar toggle, navigation title, search field).
        .toolbar(player.showNowPlaying ? .hidden : .automatic, for: .windowToolbar)
        .environment(\.openLogin, { showLogin = true })
        .task {
            await account.bootstrap()
        }
        .sheet(isPresented: $showLogin) {
            LoginSheet()
        }
        .overlay {
            if player.showNowPlaying {
                NowPlayingView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            if let toast = toasts.current {
                ToastView(toast: toast)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 12)
            }
        }
        .animation(AppAnimation.smooth, value: player.showNowPlaying)
        .animation(.spring(duration: 0.3), value: toasts.current)
    }

    private var detailStack: some View {
        NavigationStack(path: $path) {
            rootView
                .appDestinations()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PlayerBar()
        }
        .overlay(alignment: .trailing) {
            rightPanel
        }
        .animation(AppAnimation.standard, value: player.activePanel)
        .toolbar {
            if #available(macOS 26.0, *) {
                ToolbarItem(placement: .primaryAction) {
                    SearchFieldView { query in
                        path.append(Destination.search(query))
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            } else {
                ToolbarItem(placement: .primaryAction) {
                    SearchFieldView { query in
                        path.append(Destination.search(query))
                    }
                }
            }
        }
        .onChange(of: selection) {
            path = NavigationPath()
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch selection {
        case .home:
            HomeView()
        case .explore:
            ExploreView()
        case .fm:
            FMView()
        case .likedSongs:
            if let playlist = account.likedSongsPlaylist {
                PlaylistDetailView(playlistID: playlist.id, isLikedList: true)
                    .id(playlist.id)
            } else {
                loginPrompt
            }
        case .daily:
            DailySongsView()
        case .recents:
            RecentsView()
        case .collections:
            CollectionsView()
        case .cloud:
            CloudView()
        case .playlist(let id):
            PlaylistDetailView(playlistID: id)
                .id(id)
        }
    }

    private var loginPrompt: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("登录后查看你喜欢的音乐")
                .font(.headline)
            Button("登录") { showLogin = true }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var rightPanel: some View {
        if let panel = player.activePanel {
            Group {
                switch panel {
                case .lyrics:
                    LyricsPanel()
                case .queue:
                    QueuePanel()
                }
            }
            .padding(.top, 12)
            .padding(.bottom, Theme.Layout.playerBarHeight + 20)
            .padding(.trailing, 16)
            .transition(.move(edge: .trailing).combined(with: .opacity))
        }
    }
}

// MARK: - Search field

struct SearchFieldView: View {
    let onSubmit: (String) -> Void

    @State private var text = ""
    @State private var placeholder = "搜索音乐、歌手、专辑"
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 12.5))
                .focused($focused)
                .frame(width: 168)
                .onSubmit {
                    let query = text.trimmingCharacters(in: .whitespaces)
                    let effective = query.isEmpty ? placeholderQuery : query
                    guard !effective.isEmpty else { return }
                    onSubmit(effective)
                    focused = false
                }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.primary.opacity(0.05), in: Capsule())
        .overlay(Capsule().strokeBorder(.primary.opacity(focused ? 0.18 : 0.08), lineWidth: 1))
        .animation(AppAnimation.quick, value: focused)
        .task {
            if let keyword = try? await NeteaseAPI.searchDefaultKeyword(), !keyword.isEmpty {
                placeholder = keyword
                placeholderQuery = keyword
            }
        }
    }

    @State private var placeholderQuery = ""
}

// MARK: - Toast

struct ToastView: View {
    let toast: Toast

    var body: some View {
        Text(toast.message)
            .font(.system(size: 12.5, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .compatGlass(in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }
}
