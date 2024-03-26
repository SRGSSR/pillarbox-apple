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
    let configuration: (AVPlayerItem) -> Void

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading, metadata: .empty) { _ in }
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty) { _ in }
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = metadata.metadataItems
    }

    func playerItem(reload: Bool = false) -> AVPlayerItem {
        if reload, resource.isFailing {
            let item = Resource.loading.playerItem().withId(id)
            configuration(item)
            update(item: item)
            PlayerItem.reload(for: id)
            return item
        }
        else {
            let item = resource.playerItem().withId(id)
            configuration(item)
            update(item: item)
            PlayerItem.load(for: id)
            return item
        }
    }
}
