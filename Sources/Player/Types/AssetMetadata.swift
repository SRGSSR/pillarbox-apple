//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Metadata associated with an asset.
public struct AssetMetadata<CustomData> {
    /// Metadata associated with playback.
    public let playerMetadata: PlayerMetadata

    /// Custom data.
    public let customData: CustomData

    /// Creates asset metadata.
    ///
    /// - Parameters:
    ///   - playerMetadata: Metadata associated with playback.
    ///   - customData: Custom data.
    public init(playerMetadata: PlayerMetadata, customData: CustomData) {
        self.playerMetadata = playerMetadata
        self.customData = customData
    }
}
