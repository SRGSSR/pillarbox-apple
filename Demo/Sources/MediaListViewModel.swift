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

    enum Kind {
        case tvLatestMedias(vendor: SRGVendor)
    }

    @Published var state: State = .loading
    @Published var kind: Kind?
    private let trigger = Trigger()

    init() {
        $kind
            .compactMap { $0 }
            .map { [trigger] kind in
                Self.publisher(for: kind, trigger: trigger)
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func publisher(for kind: Kind, trigger: Trigger) -> AnyPublisher<State, Never> {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) {
            mediaPublisher(for: kind, trigger: trigger)
                .map { State.loaded(medias: $0) }
                .catch { Just(State.failed($0)) }
                .prepend(.loading)
        }
    }

    private static func mediaPublisher(for kind: Kind, trigger: Trigger) -> AnyPublisher<[SRGMedia], Error> {
        switch kind {
        case let .tvLatestMedias(vendor: vendor):
            return SRGDataProvider.current!.tvLatestMedias(for: vendor, pageSize: 50, paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore))
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
