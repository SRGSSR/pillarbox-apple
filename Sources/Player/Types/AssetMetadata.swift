//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// Metadata associated with an asset.
public struct AssetMetadata<CustomData> {
    /// Metadata associated with playback.
    public let playerMetadata: PlayerMetadata

    /// Custom data associated with the content.
    public let customData: CustomData

    /// Creates metadata.
    ///
    /// - Parameters:
    ///   - playerMetadata: Metadata associated with playback.
    ///   - customData: Custom data associated with the content.
    public init(playerMetadata: PlayerMetadata, customData: CustomData) {
        self.playerMetadata = playerMetadata
        self.customData = customData
    }
}
