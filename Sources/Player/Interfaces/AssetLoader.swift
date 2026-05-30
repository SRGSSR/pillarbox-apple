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

    /// A publisher that delivers the metadata associated with a given input.
    static func metadataPublisher(for input: Input) -> AnyPublisher<Metadata, Error>

    /// Converts input and metadata to an asset.
    static func asset(input: Input, metadata: Metadata) -> Asset

    /// Converts input and metadata to a downloadable asset.
    static func downloadableAsset(input: Input, metadata: Metadata) -> Asset

    /// Converts input and metadata to player metadata.
    static func playerMetadata(input: Input, metadata: Metadata) -> PlayerMetadata
}

public extension AssetLoader {
    // swiftlint:disable:next missing_docs
    static func downloadableAsset(input: Input, metadata: Metadata) -> Asset {
        asset(input: input, metadata: metadata)
    }
}

public extension AssetLoader where Metadata == PlayerMetadata {
    // swiftlint:disable:next missing_docs
    static func playerMetadata(input: Input, metadata: Metadata) -> PlayerMetadata {
        metadata
    }
}

extension AssetLoader {
    static func playerMetadata(input: Input, metadata: Metadata?) -> PlayerMetadata? {
        guard let metadata else { return nil }
        return playerMetadata(input: input, metadata: metadata)
    }
}
