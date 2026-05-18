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

extension AssetLoader {
    static func playerMetadata(from metadata: Metadata?) -> PlayerMetadata {
        guard let metadata else { return .empty }
        return playerMetadata(from: metadata)
    }

    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<Metadata>, Error> {
        metadataPublisher(for: input)
            .map { asset(input: input, metadata: $0) }
            .eraseToAnyPublisher()
    }
}
