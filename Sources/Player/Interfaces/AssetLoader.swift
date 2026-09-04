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
    static func metadataPublisher(for input: Input) -> AnyPublisher<Metadata, any Error>

    /// Converts input and metadata to an asset.
    static func asset(from input: Input, metadata: Metadata) -> Asset

    static func downloadableAssetPublisher(from input: Input, metadata: Metadata) -> AnyPublisher<Asset, Never>

    /// Converts input and metadata to player metadata.
    static func playerMetadata(from input: Input, metadata: Metadata?) -> PlayerMetadata
}

public extension AssetLoader {
    static func downloadableAssetPublisher(from input: Input, metadata: Metadata) -> AnyPublisher<Asset, Never> {
        Just(asset(from: input, metadata: metadata)).eraseToAnyPublisher()
    }
}
