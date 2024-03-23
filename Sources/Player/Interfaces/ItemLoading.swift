//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

protocol ItemLoading {
    var content: ItemContent { get }
    var contentPublisher: AnyPublisher<ItemContent, Never> { get }

    func enableTrackers(for player: Player)
    func disableTrackers()
}
