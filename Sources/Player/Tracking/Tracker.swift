//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    let item: PlayerItem
    var playerItem: AVPlayerItem

    private let player: QueuePlayer

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            if isEnabled {
                item.enableTrackers(for: player)
            }
            else {
                item.disableTrackers(with: .empty)
            }
        }
    }

    var metricEventsPublisher: AnyPublisher<[MetricEvent], Never> {
        Empty().eraseToAnyPublisher()
    }

    init(items: QueueItems, player: QueuePlayer, isEnabled: Bool) {
        self.item = items.item
        self.playerItem = items.playerItem
        self.player = player
        self.isEnabled = isEnabled

        if isEnabled {
            item.enableTrackers(for: player)
        }
    }

    deinit {
        if isEnabled {
            item.disableTrackers(with: .empty)
        }
    }
}
