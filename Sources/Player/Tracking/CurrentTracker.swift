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
            item?.disableTrackers()
        }
        didSet {
            guard let player else { return }
            item?.enableTrackers(for: player)
        }
    }

    init(player: Player) {
        self.player = player

        player.queuePublisher
            .slice(at: \.item)
            .receiveOnMainThread()
            .sink { [weak self] item in
                self?.item = item
            }
            .store(in: &cancellables)

        player.propertiesPublisher
            .receiveOnMainThread()
            .sink { [weak self] properties in
                self?.item?.updateTrackerProperties(properties)
            }
            .store(in: &cancellables)

        player.metricEventPublisher()
            .receiveOnMainThread()
            .sink { [weak self] event in
                self?.item?.receiveMetricEvent(event)
            }
            .store(in: &cancellables)
    }

    deinit {
        item?.disableTrackers()
    }
}
