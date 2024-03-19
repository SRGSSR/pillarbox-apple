//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// An adapter which instantiates and manages metadata associated with a player.
///  
/// An adapter transforms metadata delivered by a player item into a metadata format suitable for the player.
public struct MetadataAdapter<M> {
    private let playerMetadata: any PlayerMetadata
    private let update: (M) -> Void

    /// Creates an adapter for a type of metadata with the provided mapper.
    ///
    /// - Parameters:
    ///   - metadataType: The type of metadata to instantiate and manage.
    ///   - mapper: The metadata mapper.
    public init<T>(metadataType: T.Type, mapper: ((M) -> T.Metadata)?) where T: PlayerMetadata {
        let playerMetadata = metadataType.init()
        update = { metadata in
            if let mapper {
                playerMetadata.update(metadata: mapper(metadata))
            }
        }
        self.playerMetadata = playerMetadata
    }

    /// A special adapter which provides no metadata to the player.
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
