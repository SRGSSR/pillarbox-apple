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
    private static var settings: SRGMediaSearchSettings = {
        let setting = SRGMediaSearchSettings()
        setting.aggregationsEnabled = false
        return setting
    }()

    @Published var text = ""
    @Published var medias: [SRGMedia] = []

    init() {
        $text
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .map { text in
                guard !text.isEmpty else {
                    return Just([SRGMedia]())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return SRGDataProvider.current!.medias(for: .RTS, matchingQuery: text, with: Self.settings)
                    .map { output in
                        SRGDataProvider.current!.medias(withUrns: output.mediaUrns)
                    }
                    .switchToLatest()
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .replaceError(with: [SRGMedia]())
            .receiveOnMainThread()
            .assign(to: &$medias)
    }
}
