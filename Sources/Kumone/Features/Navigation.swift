import SwiftUI

extension EnvironmentValues {
    @Entry var openLogin: () -> Void = {}
}

enum SidebarItem: Hashable {
    case home
    case explore
    case fm
    case likedSongs
    case daily
    case recents
    case collections
    case cloud
    case playlist(Int)
}

enum Destination: Hashable {
    case playlist(Int)
    case album(Int)
    case artist(Int)
    case daily
    case toplists
    case search(String)
}

/// Registers all shared navigation destinations on a stack.
struct DestinationsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .playlist(let id):
                PlaylistDetailView(playlistID: id)
            case .album(let id):
                AlbumDetailView(albumID: id)
            case .artist(let id):
                ArtistDetailView(artistID: id)
            case .daily:
                DailySongsView()
            case .toplists:
                ToplistsView()
            case .search(let query):
                SearchView(query: query)
            }
        }
    }
}

extension View {
    func appDestinations() -> some View {
        modifier(DestinationsModifier())
    }
}
