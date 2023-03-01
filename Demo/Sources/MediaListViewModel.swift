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

    @Published var state: State = .loading

    init() {
        SRGDataProvider.current!.tvLatestMedias(for: .RTS)
            .map { State.loaded(medias: $0) }
            .catch { Just(State.failed($0)) }
            .receiveOnMainThread()
            .assign(to: &$state)
    }
}
