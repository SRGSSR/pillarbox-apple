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
        configureNativeMetricEventPublisher(for: player)
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
        player.metricEventPublisher
            .sink { [weak self] event in
                self?.item?.receiveMetricEvent(event)
            }
            .store(in: &cancellables)
    }

    private func configureNativeMetricEventPublisher(for player: Player) {
#if compiler(>=6.0)
        guard #available(iOS 18, tvOS 18, *) else { return }
        player.nativeMetricEventPublisher
            .sink { [weak self] event in
                self?.item?.receiveNativeMetricEvent(event)
            }
            .store(in: &cancellables)
#endif
    }

    deinit {
        item?.disableTrackers()
    }
}
