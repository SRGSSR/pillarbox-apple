//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderCombine
import SRGDataProviderModel

final class ContentListViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(contents: [Content])
        case failed(Error)
    }

    enum TriggerId {
        case reload
        case loadMore
    }

    enum Kind: Hashable {
        case tvTopics
        case latestMediasForTopic(SRGTopic)
        case tvShows
        case tvLatestMedias
        case tvLivestreams
        case tvScheduledLivestreams
        case liveCenterVideos
        case radioLivestreams
        case radioLatestMedias(radioChannel: RadioChannel)

        var radioChannel: RadioChannel? {
            switch self {
            case let .radioLatestMedias(radioChannel: radioChannel):
                return radioChannel
            default:
                return nil
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
                .map { State.loaded(contents: $0) }
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
                pageSize: 50,
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
        case .tvLatestMedias:
            return SRGDataProvider.current!.tvLatestMedias(
                for: configuration.vendor,
                pageSize: 50,
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
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case .liveCenterVideos:
            return SRGDataProvider.current!.liveCenterVideos(
                for: configuration.vendor,
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        case .radioLivestreams:
            return SRGDataProvider.current!.radioLivestreams(for: configuration.vendor)
                .map { $0.map { .media($0) } }
                .eraseToAnyPublisher()
        case let .radioLatestMedias(radioChannel: radioChannel):
            return SRGDataProvider.current!.radioLatestMedias(
                for: configuration.vendor,
                channelUid: radioChannel.rawValue,
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .map { $0.map { .media($0) } }
            .scan([], +)
            .eraseToAnyPublisher()
        }
    }

    func refresh() async {
        Task {
            try await Task.sleep(for: .milliseconds(500))
            trigger.activate(for: TriggerId.reload)
        }
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }
}
