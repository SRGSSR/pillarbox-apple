//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

extension Player {
    final class CurrentTracker {
        private let item: PlayerItem
        private var isEnabled = false
        private var cancellables = Set<AnyCancellable>()

        init(item: PlayerItem, player: Player) {
            self.item = item
            configureTrackingPublisher(player: player)
            configureAssetPublisher(for: item)
        }

        deinit {
            disableAssetIfNeeded()
        }

        private func configureTrackingPublisher(player: Player) {
            player.$isTrackingEnabled
                .sink { [weak self, weak player] enabled in
                    guard let self, let player, self.isEnabled != enabled else { return }
                    self.isEnabled = enabled
                    if enabled {
                        self.enableAsset(for: player)
                    }
                    else {
                        self.disableAsset()
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
            if isEnabled {
                disableAsset()
            }
        }
    }
}
