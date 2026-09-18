//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// A protocol that defines how URL-based content is loaded.
public protocol URLAssetLoaderProvider {
    /// Custom data associated with the content.
    associatedtype CustomData

    /// Converts the given input and metadata into an asset.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: An asset representing the content to be played. The input and metadata can be used to build custom or
    ///   encrypted assets when required.
    static func asset(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> Asset

    /// Converts input and metadata to a downloadable asset publisher.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: An asset representing the content to be downloaded. The publisher can be used to perform any kind of
    ///   required work (potentially asynchronous) to return an asset that can be downloaded.
    static func downloadableAssetPublisher(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> AnyPublisher<Asset, Never>
}

public extension URLAssetLoaderProvider {
    /// Default implementation. Immediately returns ``URLAssetLoaderProvider/asset(from:metadata:)``.
    static func downloadableAssetPublisher(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> AnyPublisher<Asset, Never> {
        Just(asset(from: input, metadata: metadata)).eraseToAnyPublisher()
    }
}
