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
    private let update: (M?, Error?) -> Void

    /// Creates an adapter for a type of metadata with the provided mapper.
    ///
    /// - Parameters:
    ///   - metadataType: The type of metadata to instantiate and manage.
    ///   - mapper: The metadata mapper.
    public init<T>(metadataType: T.Type, configuration: T.Configuration, mapper: ((M) -> T.Metadata)?) where T: PlayerMetadata {
        let playerMetadata = metadataType.init(configuration: configuration)
        update = { metadata, error in
            if let mapper, let metadata {
                playerMetadata.update(metadata: mapper(metadata), error: error)
            }
            else {
                playerMetadata.update(metadata: nil, error: error)
            }
        }
        self.playerMetadata = playerMetadata
    }

    /// A special adapter which provides no metadata to the player.
    public static func none() -> Self {
        EmptyMetadata.adapter()
    }

    func update(metadata: M?, error: Error?) {
        update(metadata, error)
    }

    func mediaItemInfo() -> NowPlayingInfo {
        playerMetadata.mediaItemInfo()
    }

    func metadataItems() -> [AVMetadataItem] {
        playerMetadata.metadataItems()
    }
}
