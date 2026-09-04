//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A protocol defining how an asset is provided.
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public protocol URLOfflineAssetProvider: URLOnlineAssetProvider where CustomData: Codable {
    /// Creates an asset.
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: CustomData) -> Asset
}
