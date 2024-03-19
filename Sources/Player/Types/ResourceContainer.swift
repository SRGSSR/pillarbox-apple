//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ResourceContainer<M>: Assetable {
    let resource: Resource
    let id: UUID
    let mapperAdapter: MapperAdapter<M>?
    let trackerAdapters: [TrackerAdapter<M>]

    init(resource: Resource, id: UUID, mapperAdapter: MapperAdapter<M>?, trackerAdapters: [TrackerAdapter<M>]) {
        self.resource = resource
        self.id = id
        self.mapperAdapter = mapperAdapter
        self.trackerAdapters = trackerAdapters
    }

    func updateMetadata() {}

    func configure(item: AVPlayerItem) {}

    func update(item: AVPlayerItem) {}
}
