//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SRGDataProviderModel

enum ContentList: Hashable {
    case tvTopics
    case latestMediasForTopic(SRGTopic)
    case tvShows
    case latestMediasForShow(SRGShow)
    case tvLatestMedias
    case tvLivestreams
    case tvScheduledLivestreams
    case liveCenterVideos
    case radioShows(radioChannel: RadioChannel)
    case radioLivestreams
    case radioLatestMedias(radioChannel: RadioChannel)

    var radioChannel: RadioChannel? {
        switch self {
        case let .radioLatestMedias(radioChannel: radioChannel), let .radioShows(radioChannel: radioChannel):
            return radioChannel
        default:
            return nil
        }
    }

    var name: String {
        switch self {
        case .tvTopics:
             return "TV Topics"
        case let .latestMediasForTopic(topic):
            return topic.title
        case .tvShows:
             return "TV Shows"
        case let .latestMediasForShow(show):
            return show.title
        case .tvLatestMedias:
             return "TV Latest Videos"
        case .tvLivestreams:
             return "TV Livestreams"
        case .tvScheduledLivestreams:
             return "Live Web"
        case .liveCenterVideos:
             return "Live Center"
        case let .radioShows(radioChannel: radioChannel):
            return radioChannel.name
        case .radioLivestreams:
             return "Radio Livestreams"
        case let .radioLatestMedias(radioChannel: radioChannel):
            return radioChannel.name
        }
    }

    var pageTitle: String {
        switch self {
        case .tvTopics:
             return "tv-topics"
        case let .latestMediasForTopic(topic):
            return topic.title
        case .tvShows:
             return "tv-shows"
        case let .latestMediasForShow(show):
            return show.title
        case .tvLatestMedias:
             return "tv-latest-videos"
        case .tvLivestreams:
             return "tv-livestreams"
        case .tvScheduledLivestreams:
             return "live-web"
        case .liveCenterVideos:
             return "live-center"
        case .radioShows:
            return "shows"
        case .radioLivestreams:
             return "radio-livestreams"
        case .radioLatestMedias:
            return "latest-audios"
        }
    }

    var pageLevels: [String] {
        ["lists"] + pageSublevels
    }

    private var pageSublevels: [String] {
        switch self {
        case .latestMediasForTopic:
            return ["topics"]
        case .latestMediasForShow:
            return ["shows"]
        case let .radioShows(radioChannel: radioChannel), let .radioLatestMedias(radioChannel: radioChannel):
            return [radioChannel.name]
        default:
            return []
        }
    }
}

extension ContentList: Identifiable {
    var id: String {
        switch self {
        case .tvTopics:
             return "tvTopics"
        case let .latestMediasForTopic(topic):
            return "latestMediasForTopic_\(topic.urn)"
        case .tvShows:
             return "tvShows"
        case let .latestMediasForShow(show):
            return "latestMediasForShow_\(show.urn)"
        case .tvLatestMedias:
             return "tvLatestMedias"
        case .tvLivestreams:
             return "tvLivestreams"
        case .tvScheduledLivestreams:
             return "tvScheduledLivestreams"
        case .liveCenterVideos:
             return "liveCenterVideos"
        case let .radioShows(radioChannel: radioChannel):
            return "radioShows_\(radioChannel.rawValue)"
        case .radioLivestreams:
             return "radioLivestreams"
        case let .radioLatestMedias(radioChannel: radioChannel):
            return "radioLatestMedias_\(radioChannel.rawValue)"
        }
    }
}

extension ContentList {
    struct Configuration: Hashable, Identifiable {
        let list: ContentList
        let vendor: SRGVendor

        var id: String {
            "\(list.id)_\(vendor.rawValue)"
        }

        var name: String {
            list.radioChannel?.name ?? vendor.name
        }
    }
}
