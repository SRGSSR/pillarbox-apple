//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A protocol defining how an asset is provided.
public protocol URLAssetProvider {
    /// Custom data associated with the content.
    associatedtype CustomData: Codable

    /// Creates an asset.
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: CustomData) -> Asset
}
