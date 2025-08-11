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

    private func playerItem(for resource: Resource, configuration: PlayerConfiguration) -> AVPlayerItem {
        let item = resource.playerItem(configuration: configuration)
            .withId(id)
            .updated(with: self)
        self.configuration.apply(to: item, metadata: metadata)
        return item
    }

    func playerItem(reload: Bool, configuration: PlayerConfiguration) -> AVPlayerItem {
        if reload, resource.isFailing {
            PlayerItem.reload(for: id)
            return playerItem(for: Resource.loading, configuration: configuration)
        }
        else {
            PlayerItem.load(for: id)
            return playerItem(for: resource, configuration: configuration)
        }
    }
}
