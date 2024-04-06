//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// An adapter which instantiates and manages metadata associated with a player.
///
/// An adapter transforms metadata delivered by a player item into a metadata format suitable for the player.
public struct MetadataAdapter<M> {
    /// A special adapter which provides no metadata to the player.
    public static var none: Self {
        EmptyMetadata.adapter()
    }

    private let map: (M) -> PlayerMetadata

    /// Creates an adapter for a type of metadata with the provided mapper.
    ///
    /// - Parameters:
    ///   - metadataType: The type of metadata to instantiate and manage.
    ///   - mapper: The metadata mapper.
    public init<T>(metadataType: T.Type, configuration: T.Configuration, mapper: ((M) -> T.Metadata)?) where T: PlayerItemMetadata {
        map = { metadata in
            guard let mapper else { return .empty }
            let playerMetadata = metadataType.init(configuration: configuration)
            let mappedMetadata = mapper(metadata)
            return .init(
                nowPlayingInfo: playerMetadata.nowPlayingInfo(from: mappedMetadata),
                items: playerMetadata.items(from: mappedMetadata),
                timedGroups: playerMetadata.timedGroups(from: mappedMetadata),
                chapterGroups: playerMetadata.chapterGroups(from: mappedMetadata)
            )
        }
    }

    func metadata(from metadata: M) -> PlayerMetadata {
        map(metadata)
    }
}
