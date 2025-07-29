//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AssetContent {
    let id: UUID
    let resource: Resource
    let metadata: PlayerMetadata
    let configuration: PlaybackConfiguration
    let dateInterval: DateInterval?

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading, metadata: .empty, configuration: .default, dateInterval: nil)
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty, configuration: .default, dateInterval: nil)
    }

    func playerItem(
        reload: Bool = false,
        playerConfiguration: PlayerConfiguration,
        playbackConfiguration: PlaybackConfiguration,
        limits: PlayerLimits
    ) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem(
                playerConfiguration: playerConfiguration,
                playbackConfiguration: playbackConfiguration,
                limits: limits
            )
            .withId(id)
            .updated(with: self)

            configure(item: item)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem(
                playerConfiguration: playerConfiguration,
                playbackConfiguration: playbackConfiguration,
                limits: limits
            )
            .withId(id)
            .updated(with: self)

            configure(item: item)
            PlayerItem.load(for: id)
            return item
        }
    }

    private func configure(item: AVPlayerItem) {
        configuration.apply(to: item, with: metadata)
    }
}
