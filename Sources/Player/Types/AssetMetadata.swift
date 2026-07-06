//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

// swiftlint:disable missing_docs

public struct AssetMetadata<CustomData> {
    public let playerMetadata: PlayerMetadata
    public let customData: CustomData

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

// swiftlint:enable missing_docs
