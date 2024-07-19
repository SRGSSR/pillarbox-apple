//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// Tracks the provided item during its lifecycle.
///
/// This class implements a Resource Acquisition Is Initialization (RAII) approach to ensure lifecycle events are
/// properly balanced.
final class CurrentTracker {
    let queueItems: QueueItems
    private var cancellables = Set<AnyCancellable>()

    init(queueItems: QueueItems, player: Player) {
        self.queueItems = queueItems

        queueItems.item.enableTrackers(for: player)

        Self.propertiesPublisher(queueItems: queueItems, player: player)
            .sink { properties in
                queueItems.item.updateTrackerProperties(properties)
            }
            .store(in: &cancellables)
    }

    private static func propertiesPublisher(queueItems: QueueItems, player: Player) -> AnyPublisher<PlayerProperties, Never> {
        Publishers.CombineLatest3(
            queueItems.propertiesPublisher(),
            player.queuePlayer.playbackPropertiesPublisher(),
            player.queuePlayer.seekTimePublisher()
        )
        .map { queueItemsProperties, playbackProperties, seekTime in
            .init(
                coreProperties: .init(
                    itemProperties: queueItemsProperties.itemProperties.itemProperties,
                    mediaSelectionProperties: queueItemsProperties.itemProperties.mediaSelectionProperties,
                    playbackProperties: playbackProperties
                ),
                timeProperties: queueItemsProperties.itemProperties.timeProperties,
                metadata: queueItemsProperties.metadata,
                metricEvents: queueItemsProperties.metricEvents,
                isEmpty: queueItemsProperties.itemProperties.isEmpty,
                seekTime: seekTime
            )
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func release(player: Player) {
        // TODO: Provide playerItem.time explicitly since player.time probably invalid? But maybe not needed if
        // cleanup is explicit?
        queueItems.item.disableTrackers(for: player)
    }
}
