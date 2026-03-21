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
    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<Metadata>, Error>

    /// Converts metadata to player metadata.
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata

    // TODO: If `Input` or `Metadata` need to be serialized we can simply add protocol methods which take an input or
    //       metadata as parameter and must return some codable type (instead of asking for `Input` and `Metadata` to
    //       themselves conform to Codable, which is more involved).
}

public extension AssetLoader where Metadata == PlayerMetadata {
    // swiftlint:disable:next missing_docs
    static func playerMetadata(from metadata: PlayerMetadata) -> PlayerMetadata {
        metadata
    }
}
