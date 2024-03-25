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
    private let convert: (M) -> Player.Metadata

    /// Creates an adapter for a type of metadata with the provided mapper.
    ///
    /// - Parameters:
    ///   - metadataType: The type of metadata to instantiate and manage.
    ///   - mapper: The metadata mapper.
    public init<T>(metadataType: T.Type, configuration: T.Configuration, mapper: ((M) -> T.Metadata)?) where T: PlayerMetadata {
        convert = { metadata in
            guard let mapper else { return .empty }
            let playerMetadata = metadataType.init(configuration: configuration)
            let mappedMetadata = mapper(metadata)
            return .init(
                mediaItemInfo: playerMetadata.mediaItemInfo(from: mappedMetadata),
                metadataItems: playerMetadata.metadataItems(from: mappedMetadata)
            )
        }
    }

    /// A special adapter which provides no metadata to the player.
    public static func none() -> Self {
        EmptyMetadata.adapter()
    }

    func metadata(from metadata: M) -> Player.Metadata {
        convert(metadata)
    }
}
