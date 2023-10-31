//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

enum RouterDestination: Identifiable, Hashable {
    case player(media: Media)
    case systemPlayer(media: Media)
    case simplePlayer(media: Media)
    case optInPlayer(media: Media)

    case vanillaPlayer(item: AVPlayerItem)

    case blurred(media: Media)
    case twins(media: Media)
    case multi(media1: Media, media2: Media)
    case link(media: Media)
    case wrapped(media: Media)
    case transition(media: Media)

    case stories
    case playlist(templates: [Template])

    case contentList(configuration: ContentList.Configuration)

    var id: String {
        switch self {
        case .player:
            return "player"
        case .systemPlayer:
            return "systemPlayer"
        case .simplePlayer:
            return "simplePlayer"
        case .optInPlayer:
            return "optInPlayer"
        case .vanillaPlayer:
            return "vanillaPlayer"
        case .blurred:
            return "blurred"
        case .twins:
            return "twins"
        case .multi:
            return "multi"
        case .link:
            return "link"
        case .wrapped:
            return "wrapped"
        case .transition:
            return "transition"
        case .stories:
            return "stories"
        case .playlist:
            return "playlist"
        case .contentList:
            return "contentList"
        }
    }

    @ViewBuilder
    func view() -> some View {
        // swiftlint:disable:previous cyclomatic_complexity
        switch self {
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

extension NavigationLink where Destination == Never {
    init<S>(_ title: S, destination: RouterDestination) where Label == Text, S: StringProtocol {
        self.init(title, value: destination)
    }
}
