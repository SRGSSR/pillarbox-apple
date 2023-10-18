//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SwiftUI

/// Manages navigation using an associated router.
struct RoutedNavigationStack<Root>: View where Root: View {
    @ViewBuilder let root: () -> Root
    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .modal(item: $router.presented) { presented in
                    view(for: presented)
                }
                .navigationDestination(for: RouterDestination.self) { destination in
                    view(for: destination)
                }
        }
        .environmentObject(router)
    }

    @ViewBuilder
    private func view(for destination: RouterDestination) -> some View {
        // swiftlint:disable:previous cyclomatic_complexity
        switch destination {
        case let .player(media: media):
            PlayerView(media: media)
        case let .systemPlayer(media: media):
            SystemPlayerView(media: media)
        case let .simplePlayer(media: media):
            SimplePlayerView(media: media)
        case let .optInPlayer(media: media):
            OptInView(media: media)
        case let .pipPlayer(media: media):
            PipPlayerView(media: media)
        case let .vanillaPlayer(item: item):
            VanillaPlayerView(item: item)
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
        case let .transition(media: media):
            TransitionView(media: media)
        case .stories:
            StoriesView()
        case let .playlist(templates: templates):
            PlaylistView(templates: templates)
        case let .contentList(configuration: configuration):
            ContentListView(configuration: configuration)
        }
    }
}

/// Manages application routes.
///
/// You can manage navigation with a `RoutedNavigationStack` or retrieve the router through the environment
/// to present the associated modal.
final class Router: ObservableObject {
    @Published fileprivate var path: [RouterDestination] = []
    @Published fileprivate var presented: RouterDestination?

    func present(_ destination: RouterDestination) {
        presented = destination
    }
}
