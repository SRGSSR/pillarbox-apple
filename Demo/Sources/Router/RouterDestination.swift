//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

enum RouterDestination: Identifiable, Hashable {
    case systemPlayer(media: Media, supportsPictureInPicture: Bool)
    case vanillaPlayer(item: AVPlayerItem)

    case contentList(configuration: ContentList.Configuration)

#if os(iOS)
    case player(media: Media, supportsPictureInPicture: Bool)
    case inlineSystemPlayer(media: Media)
    case simplePlayer(media: Media)

    case blurred(media: Media)
    case twins(media: Media)
    case multi(media1: Media, media2: Media)

    case optInPlayer(media: Media)
    case transition(media: Media)

    case link(media: Media)
    case wrapped(media: Media)

    case stories

    case playlist(medias: [Media])

    case twinsPiP(media: Media)
    case multiPiP(media1: Media, media2: Media)
    case multiSystemPiP(media1: Media, media2: Media)
    case transitionPiP(media: Media)

    case webView(url: URL)
#endif

    var id: String {
        // Treat players using the same view model as equivalent.
        switch self {
        case .systemPlayer:
            return "player"
        case .vanillaPlayer:
            return "vanillaPlayer"
        case .contentList:
            return "contentList"
#if os(iOS)
        case .player, .inlineSystemPlayer:
            return "player"
        case .simplePlayer:
            return "simplePlayer"
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
        case .stories:
            return "stories"
        case .playlist:
            return "playlist"
        case .optInPlayer:
            return "optInPlayer"
        case .transition:
            return "transition"
        case .twinsPiP:
            return "twinsPiP"
        case .multiPiP:
            return "multiPiP"
        case .multiSystemPiP:
            return "multiSystemPiP"
        case .transitionPiP:
            return "transitionPiP"
        case .webView:
            return "webView"
#endif
        }
    }

#if os(iOS)
    static func player(media: Media) -> Self {
        .player(media: media, supportsPictureInPicture: true)
    }
#endif

    static func systemPlayer(media: Media) -> Self {
        .systemPlayer(media: media, supportsPictureInPicture: true)
    }

    @ViewBuilder
    func view() -> some View {
        // swiftlint:disable:previous cyclomatic_complexity
        switch self {
        case let .systemPlayer(media: media, supportsPictureInPicture: supportsPictureInPicture):
            SystemPlayerView(media: media)
                .supportsPictureInPicture(supportsPictureInPicture)
        case let .vanillaPlayer(item: item):
            VanillaPlayerView(item: item)
        case let .contentList(configuration: configuration):
            ContentListView(configuration: configuration)
#if os(iOS)
        case let .player(media: media, supportsPictureInPicture: supportsPictureInPicture):
            PlayerView(media: media)
                .supportsPictureInPicture(supportsPictureInPicture)
        case let .inlineSystemPlayer(media: media):
            InlineSystemPlayerView(media: media)
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
        case let .playlist(medias: medias):
            PlaylistView(medias: medias)
        case let .optInPlayer(media: media):
            OptInView(media: media)
        case let .transition(media: media):
            TransitionView(media: media)
        case let .twinsPiP(media: media):
            TwinsPiPView(media: media)
        case let .multiPiP(media1: media1, media2: media2):
            MultiPiPView(media1: media1, media2: media2, isSystemPlayer: false)
        case let .multiSystemPiP(media1: media1, media2: media2):
            MultiPiPView(media1: media1, media2: media2, isSystemPlayer: true)
        case let .transitionPiP(media: media):
            TransitionPiPView(media: media)
        case let .webView(url: url):
            WebView(url: url)
#endif
        }
    }
}

extension NavigationLink where Destination == Never {
    init<S>(_ title: S, destination: RouterDestination) where Label == Text, S: StringProtocol {
        self.init(title, value: destination)
    }
}
