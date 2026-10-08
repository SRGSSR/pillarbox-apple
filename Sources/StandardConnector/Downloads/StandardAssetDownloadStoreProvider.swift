//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

/// A protocol that defines how Pillarbox-standard content is retrieved from a store.
@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public protocol StandardAssetDownloadStoreProvider: StandardAssetLoaderProvider where Input: Codable, CustomData: Codable {
    /// Creates a unique identifier for the given download input.
    ///
    /// - Parameter input: The input that identifies the download.
    /// - Returns: A string that uniquely identifies the download.
    static func id(from input: Input) -> String

    /// Creates an asset from a local file URL and custom data.
    ///
    /// - Parameters:
    ///   - fileUrl: The URL of the file to be played.
    ///   - customData: Custom data associated with the download.
    /// - Returns: A playable local asset. Implementations that create custom or encrypted assets should persist any
    ///   information needed to distinguish or reconstruct the asset in `CustomData`.
    static func asset(fileUrl: URL, customData: CustomData?) -> Asset
}
