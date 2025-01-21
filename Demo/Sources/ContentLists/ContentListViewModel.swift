//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderCombine
import SRGDataProviderModel

final class ContentListViewModel: ObservableObject, Refreshable {
    @Published var state: State = .loading
    @Published var configuration: ContentList.Configuration?
    private let trigger = Trigger()

    init() {
        $configuration
            .removeDuplicates()
            .compactMap(\.self)
            .map { [trigger] configuration in
                Self.publisher(for: configuration, trigger: trigger)
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func publisher(for configuration: ContentList.Configuration, trigger: Trigger) -> AnyPublisher<State, Never> {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
            contentPublisher(for: configuration, trigger: trigger)
                .map { State.loaded(contents: $0.removeDuplicates()) }
                .catch { Just(State.failed($0)) }
                .prepend(.loading)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private static func contentPublisher(for configuration: ContentList.Configuration, trigger: Trigger) -> AnyPublisher<[Content], Error> {
        switch configuration.list {
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
            return SRGDataProvider.current!.radioLivestreams(for: configuration.vendor, contentProviders: .all)
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

extension ContentListViewModel {
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

    enum Content: Hashable {
        case media(_ media: SRGMedia)
        case topic(_ topic: SRGTopic)
        case show(_ show: SRGShow)
    }
}
