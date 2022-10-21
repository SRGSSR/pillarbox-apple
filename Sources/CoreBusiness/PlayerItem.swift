//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

public extension PlayerItem {
    // swiftlint:disable discouraged_optional_collection

    /// Create a player item from a URN played in the specified environment.
    /// - Parameters:
    ///   - urn: The URN to play.
    ///   - automaticallyLoadedAssetKeys: The asset keys to load before the item is ready to play. If `nil` default
    ///     keys are loaded.
    ///   - environment: The environment which the URN is played from.
    convenience init(urn: String, automaticallyLoadedAssetKeys: [String]? = nil, environment: Environment = .production) {
        let publisher = DataProvider(environment: environment).recommendedPlayableResource(forUrn: urn)
            .map(\.url)
            .map { AVPlayerItem(url: $0) }
        self.init(publisher: publisher)
    }

    // swiftlint:enable discouraged_optional_collection
}
