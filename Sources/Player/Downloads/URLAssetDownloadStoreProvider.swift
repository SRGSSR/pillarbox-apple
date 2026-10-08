//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A protocol that defines how URL-based content is retrieved from a store.
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public protocol URLAssetDownloadStoreProvider: URLAssetLoaderProvider where CustomData: Codable {
    /// Creates an asset from a local file URL and custom data.
    ///
    /// - Parameters:
    ///   - fileUrl: The URL of the file to be played.
    ///   - customData: Custom data associated with the download.
    /// - Returns: A playable local asset. Implementations that create custom or encrypted assets should persist any
    ///   information needed to distinguish or reconstruct the asset in `CustomData`.
    static func asset(fileUrl: URL, customData: CustomData) -> Asset
}
