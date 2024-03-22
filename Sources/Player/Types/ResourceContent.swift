//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ResourceContent<M>: PlayerItemContent {
    let resource: Resource
    let id: UUID
    let metadataAdapter: MetadataAdapter<M>
    let trackerAdapters: [TrackerAdapter<M>]

    func updateTracker() {}
    func updateMetadata() {}

    func configure(item: AVPlayerItem) {}

    func update(item: AVPlayerItem) {}
}
