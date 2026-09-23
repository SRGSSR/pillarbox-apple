//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

public extension PlayerItem {
    /// Creates a player item from a backend endpoint providing Pillarbox-standard metadata.
    ///
    /// - Parameters:
    ///   - assetProviderType: The asset provider type.
    ///   - input: The input that identifies the asset.
    ///   - trackerAdapters: An array of `TrackerAdapter` instances to use for tracking playback events.
    ///
    /// This method fetches metadata from the provided endpoint and decodes it into a `PlayerData` object.
    ///
    /// The connector does not create the `Asset` automatically. Users must provide an `assetProvider` closure that transforms
    /// the decoded `PlayerData` into a playable `Asset`.
    static func standard<Provider>(
        assetProviderType: Provider.Type,
        input: Provider.Input,
        trackerAdapters: [TrackerAdapter<PlayerData<Provider.CustomData>>] = []
    ) -> Self where Provider: StandardAssetLoaderProvider {
        self.init(assetLoaderType: StandardAssetLoader<Provider>.self, input: input, trackerAdapters: trackerAdapters)
    }
}
