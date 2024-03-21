//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class CurrentTracker {
    private let item: PlayerItem
    private var isEnabled = false
    private var cancellables = Set<AnyCancellable>()

    init(item: PlayerItem, player: Player) {
        self.item = item
        configureMetadataUpdates(for: item)
        configureTracking(for: player)
    }

    private func configureMetadataUpdates(for item: PlayerItem) {
        item.$content
            .sink { content in
                content.updateTracker()
            }
            .store(in: &cancellables)
    }

    private func configureTracking(for player: Player) {
        player.$isTrackingEnabled
            .sink { [weak self, weak player] enabled in
                guard let self, let player, isEnabled != enabled else { return }
                isEnabled = enabled
                if enabled {
                    enableTrackers(for: player)
                }
                else {
                    disableTrackers()
                }
            }
            .store(in: &cancellables)
    }

    private func enableTrackers(for player: Player) {
        item.content.enableTrackers(for: player)
    }

    private func disableTrackers() {
        item.content.disableTrackers()
    }

    private func disableTrackersIfNeeded() {
        guard isEnabled else { return }
        disableTrackers()
    }

    deinit {
        disableTrackersIfNeeded()
    }
}
