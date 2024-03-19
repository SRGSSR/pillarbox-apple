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
    let mapperAdapter: MapperAdapter<M>?
    let trackerAdapters: [TrackerAdapter<M>]

    init(asset: Asset<M>, id: UUID, mapperAdapter: MapperAdapter<M>?, trackerAdapters: [TrackerAdapter<M>]) {
        self.asset = asset
        self.id = id
        self.mapperAdapter = mapperAdapter
        self.trackerAdapters = trackerAdapters
    }

    var resource: Resource {
        asset.resource
    }

    func updateMetadata() {
        mapperAdapter?.update(metadata: asset.metadata)
        trackerAdapters.forEach { adapter in
            adapter.update(metadata: asset.metadata)
        }
    }

    func configure(item: AVPlayerItem) {
        asset.configuration(item)
    }

    func update(item: AVPlayerItem) {
        item.externalMetadata = mapperAdapter?.metadataItems() ?? []
        // FIXME: On tvOS set navigation markers
    }
}
