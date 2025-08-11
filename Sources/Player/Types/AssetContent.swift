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
        configuration: PlayerConfiguration,
        limits: PlayerLimits,
        resumePosition: Position?
    ) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem(
                configuration: configuration,
                limits: limits
            )
            .withId(id)
            .updated(with: self)

            configure(item: item, resumePosition: resumePosition)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem(
                configuration: configuration,
                limits: limits
            )
            .withId(id)
            .updated(with: self)

            configure(item: item, resumePosition: resumePosition)
            PlayerItem.load(for: id)
            return item
        }
    }

    private func configure(item: AVPlayerItem, resumePosition: Position?) {
        configuration.apply(to: item, with: metadata, resumePosition: resumePosition)
    }
}
