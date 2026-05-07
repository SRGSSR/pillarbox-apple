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

    /// The metadata delivered with the asset.
    associatedtype Metadata

    /// A publisher that delivers the asset matching a given input.
    static func metadataPublisher(for input: Input) -> AnyPublisher<Metadata, Error>

    /// Converts input and metadata to an asset.
    static func asset(input: Input, metadata: Metadata) -> Asset<Metadata>

    /// Converts metadata to player metadata.
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata
}

public extension AssetLoader where Metadata == PlayerMetadata {
    // swiftlint:disable:next missing_docs
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata {
        metadata
    }
}
