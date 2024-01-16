//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

extension Player {
    struct Current: Equatable {
        let item: PlayerItem
        let index: Int
    }

    func currentPublisher() -> AnyPublisher<Current?, Never> {
        itemUpdatePublisher
            .map { update in
                guard let currentIndex = update.currentIndex() else { return nil }
                update.items[currentIndex].load()
                return .init(item: update.items[currentIndex], index: currentIndex)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
