//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderModel
import SwiftUI

enum Destination: Identifiable, Hashable {
    case player(media: Media)
    case systemPlayer(media: Media)
    case simplePlayer(media: Media)

    case blurred(media: Media)
    case twins(media: Media)
    case multi(media1: Media, media2: Media)
    case link(media: Media)
    case wrapped(media: Media)

    case stories
    case playlist(templates: [Template])

    case contentList(configuration: ContentListViewModel.Configuration)

    var id: String {
        switch self {
        case let .player(media):
            return "player_\(media.id)"
        case let .systemPlayer(media: media):
            return "system_player_\(media.id)"
        case let .simplePlayer(media: media):
            return "simple_player_\(media.id)"
        case let .blurred(media: media):
            return "blurred_\(media.id)"
        case let .twins(media: media):
            return "twins_\(media.id)"
        case let .multi(media1: media1, media2: media2):
            return "multi_\(media1.id)_\(media2.id)"
        case let .link(media: media):
            return "link_\(media.id)"
        case let .wrapped(media: media):
            return "wrapped_\(media.id)"
        case .stories:
            return "stories"
        case .playlist:
            return "playlist"
        case let .contentList(configuration: configuration):
            return "contentList_\(configuration.id)"
        }
    }
}

final class Router: ObservableObject {
    @Published var path: [Destination] = []
    @Published var presented: Destination?
}

extension View {
    // swiftlint:disable:next cyclomatic_complexity
    fileprivate func routed(by router: Router) -> some View {
        sheet(item: Self.presented(for: router)) { presented in
            view(for: presented)
        }
        .navigationDestination(for: Destination.self) { destination in
            view(for: destination)
        }
    }

    private static func presented(for router: Router) -> Binding<Destination?> {
        .init {
            router.presented
        } set: { newValue in
            router.presented = newValue
        }
    }

    @ViewBuilder
    private func view(for destination: Destination) -> some View {
        switch destination {
        case let .player(media: media):
            PlayerView(media: media)
        case let .systemPlayer(media: media):
            SystemPlayerView(media: media)
        case let .simplePlayer(media: media):
            SimplePlayerView(media: media)
        case let .blurred(media: media):
            BlurredView(media: media)
        case let .twins(media: media):
            TwinsView(media: media)
        case let .multi(media1: media1, media2: media2):
            MultiView(media1: media1, media2: media2)
        case let .link(media: media):
            LinkView(media: media)
        case let .wrapped(media: media):
            WrappedView(media: media)
        case .stories:
            StoriesView()
        case let .playlist(templates: templates):
            PlaylistView(templates: templates)
        case let .contentList(configuration: configuration):
            ContentListView(configuration: configuration)
        }
    }
}

struct RoutedNavigationStack<Root: View>: View {
    @ViewBuilder let root: () -> Root
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .routed(by: router)
        }
        .environmentObject(router)
    }
}
