//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class CurrentMetadata {
    let item: PlayerItem

    private let metadataSubject = CurrentValueSubject<NowPlayingInfo, Never>([:])
    private var cancellables = Set<AnyCancellable>()

    var metadataPublisher: AnyPublisher<NowPlayingInfo, Never> {
        metadataSubject.eraseToAnyPublisher()
    }

    init(item: PlayerItem) {
        self.item = item

        item.$content
            .sink { [metadataSubject] content in
                content.updateMetadata()
                metadataSubject.send(content.mediaItemInfo(with: nil))
            }
            .store(in: &cancellables)
    }
}
