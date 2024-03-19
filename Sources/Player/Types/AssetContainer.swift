//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

// TODO: Check which methods are really required in Assetable protocol and which could be omitted or in a protocol
//       extension instead. Update Assetable accordingly.

struct AssetContainer<M>: Assetable {
    private let asset: Asset<M>
    let id: UUID
    let metadataAdapter: MetadataAdapter<M>?
    let trackerAdapters: [TrackerAdapter<M>]

    var resource: Resource {
        asset.resource
    }

    init(asset: Asset<M>, id: UUID, metadataAdapter: MetadataAdapter<M>?, trackerAdapters: [TrackerAdapter<M>]) {
        self.asset = asset
        self.id = id
        self.metadataAdapter = metadataAdapter
        self.trackerAdapters = trackerAdapters
    }

    func updateMetadata() {
        metadataAdapter?.update(metadata: asset.metadata)
        trackerAdapters.forEach { adapter in
            adapter.update(metadata: asset.metadata)
        }
    }

    func configure(item: AVPlayerItem) {
        asset.configuration(item)
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = metadataAdapter?.metadataItems() ?? []
        // FIXME: On tvOS set navigation markers
    }
}
