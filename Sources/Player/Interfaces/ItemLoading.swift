//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

// TODO: Rename if tracking also managed.
protocol ItemLoading {
    var content: ItemContent { get }
    var contentPublisher: AnyPublisher<ItemContent, Never> { get }

    func enableTrackers(for player: Player)
    func disableTrackers()
}
