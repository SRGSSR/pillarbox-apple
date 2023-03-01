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

    @Published var state: State = .loading
    private let trigger = Trigger()

    init() {
        Publishers.PublishAndRepeat(onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)) { [trigger] in
            SRGDataProvider.current!.tvLatestMedias(for: .SRF, pageSize: 50, paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore))
                .scan([], +)
                .map { State.loaded(medias: $0) }
                .catch { Just(State.failed($0)) }
                .prepend(.loading)
        }
        .receiveOnMainThread()
        .assign(to: &$state)
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
