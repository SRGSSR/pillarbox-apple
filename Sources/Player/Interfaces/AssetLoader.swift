//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// A protocol defining how an asset is loaded.
public protocol AssetLoader {
    /// The input expected to load an asset.
    associatedtype Input

    /// The metadata delivered when loading an asset.
    associatedtype Metadata

    /// A publisher that delivers the asset matching a given input.
    static func publisher(for input: Input) -> AnyPublisher<Asset<Metadata>, Error>

    /// Converts metadata to player metadata.
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata
}

public extension AssetLoader where Metadata == PlayerMetadata {
    // swiftlint:disable:next missing_docs
    static func playerMetadata(from metadata: PlayerMetadata) -> PlayerMetadata {
        metadata
    }
}
