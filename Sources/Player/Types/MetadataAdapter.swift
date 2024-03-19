//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public struct MetadataAdapter<M> {
    private let playerMetadata: any PlayerMetadata
    private let update: (M) -> Void

    public init<T>(metadataType: T.Type, mapper: ((M) -> T.Metadata)?) where T: PlayerMetadata {
        let playerMetadata = metadataType.init()
        update = { metadata in
            if let mapper {
                playerMetadata.update(metadata: mapper(metadata))
            }
        }
        self.playerMetadata = playerMetadata
    }

    public static func none() -> Self {
        EmptyMetadata.adapter()
    }

    func update(metadata: M) {
        update(metadata)
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        playerMetadata.mediaItemInfo(with: error)
    }

    func metadataItems() -> [AVMetadataItem] {
        playerMetadata.metadataItems()
    }

    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        playerMetadata.navigationMarkerGroups()
    }
}
