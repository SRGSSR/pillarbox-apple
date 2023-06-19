//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Foundation
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

    case stories
    case playlist(templates: [Template])

    case contentList(configuration: ContentListConfiguration)

    var id: String {
        switch self {
        case let .player(media):
            return "player_\(media.id)"
        case let .systemPlayer(media: media):
            return "systemPlayer_\(media.id)"
        case let .simplePlayer(media: media):
            return "simplePlayer_\(media.id)"
        case let .optInPlayer(media: media):
            return "optInPlayer_\(media.id)"
        case let .vanillaPlayer(item: item):
            return "vanillaPlayer\(item.hash)"
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

extension NavigationLink where Destination == Never {
    init(_ titleKey: LocalizedStringKey, destination: RouterDestination) where Label == Text {
        self.init(titleKey, value: destination)
    }

    init<S>(_ title: S, destination: RouterDestination) where Label == Text, S: StringProtocol {
        self.init(title, value: destination)
    }
}
