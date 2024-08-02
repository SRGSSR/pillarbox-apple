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

    @objc dynamic var playerItem: AVPlayerItem {
        didSet {
            configurePlayerItemPublishers()
        }
    }

    private var properties: PlayerProperties = .empty

    private var itemMetricEventSubject = PassthroughSubject<MetricEvent, Never>()
    private var playerItemMetricEventSubject = PassthroughSubject<MetricEvent, Never>()

    private let player: QueuePlayer

    private var itemCancellables = Set<AnyCancellable>()
    private var playerItemCancellables = Set<AnyCancellable>()

    @Published private(set) var metricEvents: [MetricEvent] = []

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

    init(items: QueueItems, player: QueuePlayer, isEnabled: Bool) {
        self.item = items.item
        self.playerItem = items.playerItem
        self.player = player
        self.isEnabled = isEnabled
        super.init()

        if isEnabled {
            item.enableTrackers(for: player)
        }

        configureItemPublishers()
        configurePlayerItemPublishers()
    }

    private func configureItemPublishers() {
        publisher(for: \.playerItem)
            .map { [player] playerItem in
                playerItem.propertiesPublisher(with: player)
            }
            .switchToLatest()
            .weakAssign(to: \.properties, on: self)
            .store(in: &itemCancellables)
        Publishers.Merge(itemMetricEventSubject, playerItemMetricEventSubject)
            .scan([]) { $0 + [$1] }
            .assign(to: &$metricEvents)
        item.metricEventPublisher()
            .assign(on: itemMetricEventSubject)
            .store(in: &itemCancellables)
    }

    private func configurePlayerItemPublishers() {
        playerItemCancellables = []
        playerItem.metricEventPublisher()
            .assign(on: playerItemMetricEventSubject)
            .store(in: &playerItemCancellables)
    }

    deinit {
        if isEnabled {
            item.disableTrackers(with: properties)
        }
    }
}
