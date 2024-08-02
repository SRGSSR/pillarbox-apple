//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class Tracker: NSObject {
    let item: PlayerItem

    @objc dynamic var playerItem: AVPlayerItem

    private var properties: PlayerProperties = .empty

    private let player: QueuePlayer
    private var cancellables = Set<AnyCancellable>()

    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            if isEnabled {
                item.enableTrackers(for: player)
            }
            else {
                item.disableTrackers(with: properties)
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
        super.init()

        if isEnabled {
            item.enableTrackers(for: player)
        }

        configurePropertiesPublisher(with: player)
    }

    private func configurePropertiesPublisher(with player: QueuePlayer) {
        publisher(for: \.playerItem)
            .map { playerItem in
                playerItem.propertiesPublisher(with: player)
            }
            .switchToLatest()
            .weakAssign(to: \.properties, on: self)
            .store(in: &cancellables)
    }

    deinit {
        if isEnabled {
            item.disableTrackers(with: properties)
        }
    }
}
