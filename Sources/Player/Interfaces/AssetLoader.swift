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

    /// Converts the given input and metadata into player metadata.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: Player metadata describing the asset.
    static func playerMetadata(from input: Input, metadata: Metadata?) -> PlayerMetadata
}
