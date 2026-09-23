//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxPlayer

/// A protocol that defines how Pillarbox-standard-based content is loaded.
public protocol StandardAssetLoaderProvider {
    /// The input expected to load an asset.
    associatedtype Input

    /// Custom data associated with the content.
    associatedtype CustomData: Decodable

    /// The request to load the metadata
    ///
    /// - Parameter input: The input that identifies the asset.
    static func request(for input: Input) -> URLRequest

    /// The decoder to parse the custom data.
    static func decoder() -> JSONDecoder

    /// Converts the given input and metadata into an asset.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: An asset representing the content to be played. The input and metadata can be used to build custom or
    ///   encrypted assets when required.
    static func asset(from input: Input, metadata: PlayerData<CustomData>) -> Asset

    /// Converts input and metadata to a downloadable asset publisher.
    ///
    /// - Parameters:
    ///   - input: The input that identifies the asset.
    ///   - metadata: The metadata associated with the asset.
    /// - Returns: An asset representing the content to be downloaded. The publisher can be used to perform any kind of
    ///   required work (potentially asynchronous) to return an asset that can be downloaded.
    ///
    /// If not implemented defaults to a publisher immediately returning ``StandardAssetLoaderProvider/asset(from:metadata:)``.
    static func downloadableAssetPublisher(from input: Input, metadata: PlayerData<CustomData>) -> AnyPublisher<Asset, Never>
}

public extension StandardAssetLoaderProvider {
    /// Default implementation. Immediately returns ``StandardAssetLoaderProvider/asset(from:metadata:)``.
    static func downloadableAssetPublisher(from input: Input, metadata: PlayerData<CustomData>) -> AnyPublisher<Asset, Never> {
        Just(asset(from: input, metadata: metadata)).eraseToAnyPublisher()
    }

    /// Default implementation.
    static func decoder() -> JSONDecoder {
        .init()
    }
}
