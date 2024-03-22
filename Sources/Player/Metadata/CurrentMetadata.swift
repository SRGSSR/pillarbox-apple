//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class CurrentMetadata {
    let item: PlayerItem
    private let metadataSubject = CurrentValueSubject<Player.Metadata, Never>(.empty)
    private var cancellables = Set<AnyCancellable>()

    var metadataPublisher: AnyPublisher<Player.Metadata, Never> {
        metadataSubject.eraseToAnyPublisher()
    }

    init(item: PlayerItem, error: Error?) {
        self.item = item
        item.$content
            .sink { [metadataSubject] content in
                content.updateMetadata(error: error)
                metadataSubject.send(content.metadata())
            }
            .store(in: &cancellables)
    }
}
