//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

// swiftlint:disable missing_docs

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public protocol URLAssetDownloadStoreProvider: URLAssetLoaderProvider where CustomData: Codable {
    /// Creates an asset.
    static func asset(fileUrl: URL, customData: CustomData) -> Asset
}

// swiftlint:enable missing_docs
