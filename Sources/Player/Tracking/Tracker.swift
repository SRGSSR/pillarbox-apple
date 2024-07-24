//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final class Tracker {
    private var cancellables = Set<AnyCancellable>()
    private let player: QueuePlayer

    var items: QueueItems? {
        willSet {
            guard let items, newValue?.item != items.item else { return }
            items.item.disableTrackers(with: .empty, time: items.playerItem.currentTime())
        }
        didSet {
            cancellables = []
            guard let items else { return }
            if oldValue?.item != items.item {
                items.item.enableTrackers(for: player)
            }
            player.propertiesPublisher(with: items.playerItem)
                .sink { properties in
                    items.item.updateTrackerProperties(with: properties, time: items.playerItem.currentTime())
                }
                .store(in: &cancellables)
        }
    }

    init(player: QueuePlayer) {
        self.player = player
    }

    deinit {
        guard let items else { return }
        items.item.disableTrackers(with: .empty, time: items.playerItem.currentTime())
    }
}
