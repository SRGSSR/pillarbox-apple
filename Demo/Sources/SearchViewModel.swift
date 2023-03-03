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
            .map { Self.mediasPublisher(text: $0) }
            .switchToLatest()
            .replaceError(with: [])
            .receiveOnMainThread()
            .assign(to: &$medias)
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
