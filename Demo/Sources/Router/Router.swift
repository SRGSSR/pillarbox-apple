//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderModel
import SwiftUI

/// A navigation stack managed by a router.
struct RoutedNavigationStack<Root: View>: View {
    @ViewBuilder let root: () -> Root
    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            root()
                .sheet(item: $router.presented) { presented in
                    view(for: presented)
                }
                .navigationDestination(for: Destination.self) { destination in
                    view(for: destination)
                }
        }
        .environmentObject(router)
    }

    @ViewBuilder
    private func view(for destination: Destination) -> some View {
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
        case .stories:
            StoriesView()
        case let .playlist(templates: templates):
            PlaylistView(templates: templates)
        case let .contentList(configuration: configuration):
            ContentListView(configuration: configuration)
        }
    }
}

final class Router: ObservableObject {
    @Published fileprivate var path: [Destination] = []
    @Published fileprivate var presented: Destination?

    func present(_ destination: Destination) {
        presented = destination
    }

    func dismiss() {
        presented = nil
    }
}
