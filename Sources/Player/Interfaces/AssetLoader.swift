//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// A protocol defining how an asset is loaded and persisted.
public protocol DownloadableAssetLoader: AssetLoader {
    // TODO: We should manage an identifier (e.g. Hashable)
    static func identifier(from input: Input) -> String

    static func setInput(_ input: Input, for identifier: String)
    static func setMetadata(_ metadata: Metadata, for identifier: String)

    static func input(for identifier: String) -> Input?
    static func metadata(for identifier: String) -> Metadata?

    static func remove(for identifier: String)
}

extension DownloadableAssetLoader {
    static func assetContentPublisher(for downloadMetadata: DownloadMetadata) -> AnyPublisher<AssetContent, Never>? {
        guard let input = input(for: downloadMetadata.assetId) else { return nil }
        return assetPublisher(for: input)
            .map { asset in
                Publishers.CombineLatest(
                    Just(asset),
                    playerMetadata(from: asset.metadata).playerMetadataPublisher(),
                )
            }
            .switchToLatest()
            .map { asset, metadata in
                .loaded(
                    id: downloadMetadata.id,
                    resource: asset.resource,
                    metadata: metadata,
                    configuration: asset.configuration,
                    serviceInterval: nil
                )
            }
            .catch { error in
                Just(.failing(id: downloadMetadata.id, error: error))
            }
            .eraseToAnyPublisher()
    }

    static func playerMetadata(for downloadMetadata: DownloadMetadata) -> PlayerMetadata? {
        guard let metadata = metadata(for: downloadMetadata.assetId) else { return nil }
        return playerMetadata(from: metadata)
    }
}

/// A protocol defining how an asset is loaded.
public protocol AssetLoader {
    /// The input expected to load an asset.
    associatedtype Input

    /// The metadata delivered with the asset.
    associatedtype Metadata

    /// A publisher that delivers the asset matching a given input.
    static func assetPublisher(for input: Input) -> AnyPublisher<Asset<Metadata>, Error>

    /// Converts metadata to player metadata.
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata
}

public extension AssetLoader where Metadata == PlayerMetadata {
    // swiftlint:disable:next missing_docs
    static func playerMetadata(from metadata: Metadata) -> PlayerMetadata {
        metadata
    }
}
