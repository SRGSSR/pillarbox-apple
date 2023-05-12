//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderCombine
import SRGDataProviderModel

final class ContentListViewModel: ObservableObject, Refreshable {
    enum State: Equatable {
        case loading
        case loaded(contents: [Content])
        case failed(Error)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.loading, .loading):
                return true
            case let (.loaded(contents: lhsContents), .loaded(contents: rhsContents)):
                return lhsContents == rhsContents
            case let (.failed(lhsError), .failed(rhsError)):
                return lhsError as NSError == rhsError as NSError
            default:
                return false
            }
        }
    }

    enum TriggerId {
        case reload
        case loadMore
    }

    enum Kind: Hashable {
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

    enum Content: Hashable {
        case media(_ media: SRGMedia)
        case topic(_ topic: SRGTopic)
        case show(_ show: SRGShow)
    }

    struct Configuration: Hashable {
        let kind: Kind
        let vendor: SRGVendor

        var name: String {
            kind.radioChannel?.name ?? vendor.name
        }
    }

    @Published var state: State = .loading
    @Published var configuration: Configuration?
    private let trigger = Trigger()

    init() {
        $configuration
            .removeDuplicates()
            .compactMap { $0 }
            .map { [trigger] configuration in
                Self.publisher(for: configuration, trigger: trigger)
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func publisher(for configuration: Configuration, trigger: Trigger) -> AnyPublisher<State, Never> {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
            contentPublisher(for: configuration, trigger: trigger)
                .map { State.loaded(contents: $0.removeDuplicates()) }
                .catch { Just(State.failed($0)) }
                .prepend(.loading)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func contentPublisher(for configuration: Configuration, trigger: Trigger) -> AnyPublisher<[Content], Error> {
        switch configuration.kind {
        case .tvTopics:
            return SRGDataProvider.current!.tvTopics(for: configuration.vendor)
                .map { $0.map { .topic($0) } }
                .eraseToAnyPublisher()
        case let .latestMediasForTopic(topic):
            return SRGDataProvider.current!.latestMediasForTopic(
                withUrn: topic.urn,
                pageSize: kPageSize,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case .tvShows:
            return SRGDataProvider.current!.tvShows(
                for: configuration.vendor,
                pageSize: SRGDataProviderUnlimitedPageSize
            )
            .map { $0.map { .show($0) } }
            .eraseToAnyPublisher()
        case let .latestMediasForShow(show):
            return SRGDataProvider.current!.latestMediasForShow(
                withUrn: show.urn,
                pageSize: kPageSize,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case .tvLatestMedias:
            return SRGDataProvider.current!.tvLatestMedias(
                for: configuration.vendor,
                pageSize: kPageSize,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case .tvLivestreams:
            return SRGDataProvider.current!.tvLivestreams(for: configuration.vendor)
                .map { $0.map { .media($0) } }
                .eraseToAnyPublisher()
        case .tvScheduledLivestreams:
            return SRGDataProvider.current!.tvScheduledLivestreams(
                for: configuration.vendor,
                pageSize: kPageSize,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case .liveCenterVideos:
            return SRGDataProvider.current!.liveCenterVideos(
                for: configuration.vendor,
                pageSize: kPageSize,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case let .radioShows(radioChannel: radioChannel):
            return SRGDataProvider.current!.radioShows(
                for: configuration.vendor,
                channelUid: radioChannel.rawValue,
                pageSize: SRGDataProviderUnlimitedPageSize
            )
            .map { $0.map { .show($0) } }
            .eraseToAnyPublisher()
        case .radioLivestreams:
            return SRGDataProvider.current!.radioLivestreams(for: configuration.vendor)
                .map { $0.map { .media($0) } }
                .eraseToAnyPublisher()
        case let .radioLatestMedias(radioChannel: radioChannel):
            return SRGDataProvider.current!.radioLatestMedias(
                for: configuration.vendor,
                channelUid: radioChannel.rawValue,
                pageSize: kPageSize,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        }
    }

    func refresh() async {
        Task {
            try? await Task.sleep(for: .seconds(1))
            trigger.activate(for: TriggerId.reload)
        }
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }
}
