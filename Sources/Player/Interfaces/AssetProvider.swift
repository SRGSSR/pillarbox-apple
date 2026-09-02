//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A protocol defining how an asset is provided.
public protocol AssetProvider {
    /// Custom data associated with the content.
    associatedtype CustomData

    /// Creates an asset.
    static func asset(url: URL, configuration: PlaybackConfiguration, customData: CustomData) -> Asset
}
