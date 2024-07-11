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

        configureItemPublisher(for: player)
        configurePropertiesPublisher(for: player)
        configureMetricEventPublisher(for: player)
    }

    private func configureItemPublisher(for player: Player) {
        player.queuePublisher
            .slice(at: \.item)
            .receiveOnMainThread()
            .sink { [weak self] item in
                self?.item = item
            }
            .store(in: &cancellables)
    }

    private func configurePropertiesPublisher(for player: Player) {
        player.propertiesPublisher
            .receiveOnMainThread()
            .sink { [weak self] properties in
                self?.item?.updateTrackerProperties(properties)
            }
            .store(in: &cancellables)
    }

    private func configureMetricEventPublisher(for player: Player) {
        player.metricEventsPublisher
            .sink { [weak self] events in
                guard let item = self?.item else { return }
                events.forEach { event in
                    item.receiveMetricEvent(event)
                }
            }
            .store(in: &cancellables)
    }

    deinit {
        item?.disableTrackers()
    }
}
