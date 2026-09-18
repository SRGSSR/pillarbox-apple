//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

// swiftlint:disable missing_docs

public protocol URLAssetLoaderProvider {
    /// Custom data associated with the content.
    associatedtype CustomData

    /// Creates an asset.
    static func asset(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> Asset
    static func downloadableAssetPublisher(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> AnyPublisher<Asset, Never>
}

public extension URLAssetLoaderProvider {
    static func downloadableAssetPublisher(from input: URLInput<CustomData>, metadata: AssetMetadata<CustomData>) -> AnyPublisher<Asset, Never> {
        Just(asset(from: input, metadata: metadata)).eraseToAnyPublisher()
    }
}

// swiftlint:enable missing_docs
