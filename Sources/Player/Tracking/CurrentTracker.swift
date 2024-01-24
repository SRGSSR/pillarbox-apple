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
        configureTrackingPublisher(player: player)
        configureAssetPublisher(for: item)
    }

    private func configureTrackingPublisher(player: Player) {
        player.$isTrackingEnabled
            .sink { [weak self, weak player] enabled in
                guard let self, let player, isEnabled != enabled else { return }
                isEnabled = enabled
                if enabled {
                    enableAsset(for: player)
                }
                else {
                    disableAsset()
                }
            }
            .store(in: &cancellables)
    }

    private func configureAssetPublisher(for item: PlayerItem) {
        item.$asset
            .sink { asset in
                asset.updateMetadata()
            }
            .store(in: &cancellables)
    }

    private func enableAsset(for player: Player) {
        item.asset.enable(for: player)
    }

    private func disableAsset() {
        item.asset.disable()
    }

    private func disableAssetIfNeeded() {
        guard isEnabled else { return }
        disableAsset()
    }

    deinit {
        disableAssetIfNeeded()
    }
}
