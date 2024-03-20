//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ResourceContainer<M>: Assetable {
    let resource: Resource
    let id: UUID
    let metadataAdapter: MetadataAdapter<M>
    let trackerAdapters: [TrackerAdapter<M>]

    func updateMetadata() {}

    func configure(item: AVPlayerItem) {}

    func update(item: AVPlayerItem) {}
}
