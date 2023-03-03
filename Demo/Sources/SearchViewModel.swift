//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import SRGDataProvider
import SRGDataProviderModel

final class SearchViewModel: ObservableObject {
    enum State {
        case loading
        case loaded(medias: [SRGMedia])
        case failed(Error)
    }

    private static var settings: SRGMediaSearchSettings = {
        let setting = SRGMediaSearchSettings()
        setting.aggregationsEnabled = false
        return setting
    }()

    @Published var text = ""
    @Published var state: State = .loading

    init() {
        $text
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { text in
                Self.mediasPublisher(text: text)
                    .map { State.loaded(medias: $0) }
                    .catch { Just(State.failed($0)) }
                    .prepend(.loading)
            }
            .switchToLatest()
            .receiveOnMainThread()
            .assign(to: &$state)
    }

    private static func mediasPublisher(text: String) -> AnyPublisher<[SRGMedia], Error> {
        guard !text.isEmpty else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return SRGDataProvider.current!.medias(for: .RTS, matchingQuery: text, with: settings)
            .map { output in
                SRGDataProvider.current!.medias(withUrns: output.mediaUrns)
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
