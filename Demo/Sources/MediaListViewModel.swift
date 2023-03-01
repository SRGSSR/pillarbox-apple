//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import SRGDataProviderCombine
import SRGDataProviderModel

final class MediaListViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(medias: [SRGMedia])
        case failed(Error)
    }

    enum TriggerId {
        case reload
        case loadMore
    }

    enum Kind: Hashable {
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
            mediaPublisher(for: configuration, trigger: trigger)
                .map { State.loaded(medias: $0) }
                .catch { Just(State.failed($0)) }
                .prepend(.loading)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private static func mediaPublisher(for configuration: Configuration, trigger: Trigger) -> AnyPublisher<[SRGMedia], Error> {
        switch configuration.kind {
        case .tvLatestMedias:
            return SRGDataProvider.current!.tvLatestMedias(
                for: configuration.vendor,
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .scan([], +)
            .eraseToAnyPublisher()
        case .tvLivestreams:
            return SRGDataProvider.current!.tvLivestreams(for: configuration.vendor)
                .eraseToAnyPublisher()
        case .tvScheduledLivestreams:
            return SRGDataProvider.current!.tvScheduledLivestreams(
                for: configuration.vendor,
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .scan([], +)
            .eraseToAnyPublisher()
        case .liveCenterVideos:
            return SRGDataProvider.current!.liveCenterVideos(
                for: configuration.vendor,
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .scan([], +)
            .eraseToAnyPublisher()
        case .radioLivestreams:
            return SRGDataProvider.current!.radioLivestreams(for: configuration.vendor)
                .eraseToAnyPublisher()
        case let .radioLatestMedias(radioChannel: radioChannel):
            return SRGDataProvider.current!.radioLatestMedias(
                for: configuration.vendor,
                channelUid: radioChannel.rawValue,
                pageSize: 50,
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
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
