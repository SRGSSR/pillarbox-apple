//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    let item: PlayerItem

    var playerItem: AVPlayerItem {
        didSet {
            print("--> update tracker \(item.id) with player item \(playerItem)")
        }
    }

    var isEnabled: Bool

    init(items: QueueItems, player: QueuePlayer, isEnabled: Bool) {
        self.item = items.item
        self.playerItem = items.playerItem
        self.isEnabled = isEnabled
        print("--> create tracker \(item.id) with player item \(playerItem)")
    }

    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        Empty().eraseToAnyPublisher()
    }

    deinit {
        print("--> destroy tracker \(item.id)")
    }
}
