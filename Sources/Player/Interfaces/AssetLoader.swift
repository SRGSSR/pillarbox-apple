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

    /// Defines a publisher that delivers metadata for the asset associated with the given input.
    ///
    /// - Parameter input: The input that identifies the asset.
    /// - Returns: A publisher that delivers the metadata associated with the given input.
    static func metadataPublisher(for input: Input) -> AnyPublisher<Metadata, any Error>

    /// Converts the given input and metadata into an asset.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: An asset representing the content to be played. The input and metadata can be used to build custom or
    ///   encrypted assets when required.
    static func asset(from input: Input, metadata: Metadata) -> Asset

    /// Converts input and metadata to a downloadable asset publisher.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: An asset representing the content to be downloaded. The publisher can be used to perform any kind of
    ///   required work (potentially asynchronous) to return an asset that can be downloaded.
    ///
    ///
    /// If not implemented defaults to a publisher immediately returning ``AssetLoader/asset(from:metadata:)``.
    static func downloadableAssetPublisher(from input: Input, metadata: Metadata) -> AnyPublisher<Asset, Never>

    /// Converts the given input and metadata into player metadata.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: Player metadata describing the asset.
    static func playerMetadata(from input: Input, metadata: Metadata?) -> PlayerMetadata
}

public extension AssetLoader {
    /// Default implementation. Immediately returns ``AssetLoader/asset(from:metadata:)``.
    static func downloadableAssetPublisher(from input: Input, metadata: Metadata) -> AnyPublisher<Asset, Never> {
        Just(asset(from: input, metadata: metadata)).eraseToAnyPublisher()
    }
}
