//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AssetContent {
    let id: UUID
    let resource: Resource
    let metadata: Player.Metadata

    static func loading(id: UUID) -> Self {
        .init(id: id, resource: .loading, metadata: .empty)
    }

    static func failing(id: UUID, error: Error) -> Self {
        .init(id: id, resource: .failing(error: error), metadata: .empty)
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = metadata.metadataItems
    }
}
