//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class CurrentTracker {
    private var cancellables = Set<AnyCancellable>()
    private weak var player: Player?

    private var item: PlayerItem? {
        willSet {
            guard item != newValue else { return }
            item?.disableTrackers()
        }
        didSet {
            guard let player, item != oldValue else { return }
            item?.enableTrackers(for: player)
        }
    }

    init(player: Player) {
        self.player = player

        player.queuePublisher
            .slice(at: \.item)
            .sink { [weak self] item in
                self?.item = item
            }
            .store(in: &cancellables)

        player.propertiesPublisher
            .sink { [weak self] properties in
                self?.item?.updateTrackerProperties(properties)
            }
            .store(in: &cancellables)

        player.metricEventPublisher()
            .sink { [weak self] event in
                self?.item?.receiveMetricEvent(event)
            }
            .store(in: &cancellables)
    }

    deinit {
        item?.disableTrackers()
    }
}
