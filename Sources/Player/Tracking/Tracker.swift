//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    private let player: AVPlayer

    var items: QueueItems? {
        willSet {
            guard let items, newValue?.item != items.item else { return }
            items.item.disableTrackers(with: .empty, time: items.playerItem.currentTime())
        }
        didSet {
            guard oldValue?.item != items?.item else { return }
            items?.item.enableTrackers(for: player)
        }
    }

    init(player: AVPlayer) {
        self.player = player
    }

    deinit {
        guard let items else { return }
        items.item.disableTrackers(with: .empty, time: items.playerItem.currentTime())
    }
}
