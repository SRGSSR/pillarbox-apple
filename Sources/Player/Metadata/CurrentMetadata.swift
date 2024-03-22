//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class CurrentMetadata {
    let item: PlayerItem
    let error: Error?

    private let metadataSubject = CurrentValueSubject<Player.Metadata, Never>(.empty)
    private var cancellables = Set<AnyCancellable>()

    var metadataPublisher: AnyPublisher<Player.Metadata, Never> {
        metadataSubject.eraseToAnyPublisher()
    }

    init(item: PlayerItem, error: Error?) {
        self.item = item
        self.error = error

        item.$content
            .sink { [metadataSubject] content in
                content.updateMetadata()
                metadataSubject.send(content.metadata(with: error))
            }
            .store(in: &cancellables)
    }
}
