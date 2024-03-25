//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AssetContent<M>: PlayerItemContent {
    private let asset: Asset<M>
    let id: UUID
    let metadataAdapter: MetadataAdapter<M>
    let trackerAdapters: [TrackerAdapter<M>]

    var resource: Resource {
        asset.resource
    }

    init(asset: Asset<M>, id: UUID, metadataAdapter: MetadataAdapter<M>, trackerAdapters: [TrackerAdapter<M>]) {
        self.asset = asset
        self.id = id
        self.metadataAdapter = metadataAdapter
        self.trackerAdapters = trackerAdapters
    }

    func updateTracker() {
        trackerAdapters.forEach { adapter in
            adapter.update(metadata: asset.metadata)
        }
    }

    func configure(item: AVPlayerItem) {
        asset.configuration(item)
    }

    func update(item: AVPlayerItem) {
        // item.externalMetadata
        // FIXME: On tvOS set navigation markers
    }
}
