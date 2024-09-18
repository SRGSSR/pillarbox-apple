//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import SwiftUI

enum RouterDestination: Identifiable, Hashable {
    case player(media: Media, supportsPictureInPicture: Bool)
    case systemPlayer(media: Media, supportsPictureInPicture: Bool)
    case inlineSystemPlayer(media: Media)
    case simplePlayer(media: Media)
    case optInPlayer(media: Media)

    case vanillaPlayer(item: AVPlayerItem)

    case blurred(media: Media)
    case twins(media: Media)
    case multi(media1: Media, media2: Media)

    case link(media: Media)
    case wrapped(media: Media)
    case transition(media: Media)

    case twinsBasicPiP(media: Media)
    case twinsAdvancedPiP(media: Media)
    case multiBasicPiP(media1: Media, media2: Media)
    case transitionBasicPiP(media: Media)
    case transitionAdvancedPiP(media: Media)

    case stories
    case playlist(medias: [Media])

    case contentList(configuration: ContentList.Configuration)

#if os(iOS)
    case webView(url: URL)
#endif

    var id: String {
        // Treat players using the same view model as equivalent.
        switch self {
        case .player, .systemPlayer, .inlineSystemPlayer:
            return "player"
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
        case .twinsBasicPiP:
            return "twinsBasicPiP"
        case .twinsAdvancedPiP:
            return "twinsAdvancedPiP"
        case .multiBasicPiP:
            return "multiBasicPiP"
        case .transitionBasicPiP:
            return "transitionBasicPiP"
        case .transitionAdvancedPiP:
            return "transitionAdvancedPiP"
        case .stories:
            return "stories"
        case .playlist:
            return "playlist"
        case .contentList:
            return "contentList"
#if os(iOS)
        case .webView:
            return "webView"
#endif
        }
    }

    static func player(media: Media) -> Self {
        .player(media: media, supportsPictureInPicture: true)
    }

    static func systemPlayer(media: Media) -> Self {
        .systemPlayer(media: media, supportsPictureInPicture: true)
    }

    @ViewBuilder
    func view() -> some View {
        // swiftlint:disable:previous cyclomatic_complexity
        switch self {
        case let .player(media: media, supportsPictureInPicture: supportsPictureInPicture):
            PlayerView(media: media)
                .supportsPictureInPicture(supportsPictureInPicture)
        case let .systemPlayer(media: media, supportsPictureInPicture: supportsPictureInPicture):
            SystemPlayerView(media: media)
                .supportsPictureInPicture(supportsPictureInPicture)
        case let .inlineSystemPlayer(media: media):
            InlineSystemPlayerView(media: media)
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
        case let .twinsBasicPiP(media: media):
            TwinsBasicPiPView(media: media)
        case let .twinsAdvancedPiP(media: media):
            TwinsAdvancedPiPView(media: media)
        case let .multiBasicPiP(media1: media1, media2: media2):
            MultiBasicPiPView(media1: media1, media2: media2)
        case let .transitionBasicPiP(media: media):
            TransitionBasicPiPView(media: media)
        case let .transitionAdvancedPiP(media: media):
            TransitionAdvancedPiPView(media: media)
        case .stories:
            StoriesView()
        case let .playlist(medias: medias):
            PlaylistView(medias: medias)
        case let .contentList(configuration: configuration):
            ContentListView(configuration: configuration)
#if os(iOS)
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
