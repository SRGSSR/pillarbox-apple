//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// Describes metadata associated with an asset.
public struct AssetMetadata<CustomData> {
    /// Standard playback metadata.
    public let playerMetadata: PlayerMetadata

    /// Custom data.
    public let customData: CustomData

    /// Creates asset metadata.
    ///
    /// - Parameters:
    ///   - playerMetadata: Standard playback metadata.
    ///   - customData: Custom data.
    public init(playerMetadata: PlayerMetadata, customData: CustomData) {
        self.playerMetadata = playerMetadata
        self.customData = customData
    }

    func withoutCustomData() -> AssetMetadata<Void> {
        .init(playerMetadata: playerMetadata, customData: ())
    }

    func assetMetadataPublisher() -> AnyPublisher<AssetMetadata<CustomData>, Never> {
        Publishers.CombineLatest(
            playerMetadata.playerMetadataPublisher(),
            Just(customData)
        )
        .map { .init(playerMetadata: $0, customData: $1) }
        .eraseToAnyPublisher()
    }
}

extension AssetMetadata: Codable where CustomData: Codable {}
