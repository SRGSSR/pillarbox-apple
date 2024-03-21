//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class CurrentMetadata {
    let item: PlayerItem
    private var cancellables = Set<AnyCancellable>()

    init(item: PlayerItem) {
        self.item = item

        item.$content
            .sink { content in
                content.updateMetadata()
            }
            .store(in: &cancellables)
    }
}
