//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

public struct AssetMetadata<CustomData> {
    public let playerMetadata: PlayerMetadata
    public let customData: CustomData

    init(playerMetadata: PlayerMetadata, customData: CustomData) {
        self.playerMetadata = playerMetadata
        self.customData = customData
    }
}
