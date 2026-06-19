//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

#if DEBUG

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
}

public extension AssetMetadata where CustomData == Void {
    static let empty = Self(playerMetadata: .empty, customData: ())
}

extension AssetMetadata: Codable where CustomData: Codable {}

#endif

// swiftlint:enable missing_docs
