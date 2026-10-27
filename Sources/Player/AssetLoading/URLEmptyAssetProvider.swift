//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A provider that manages no custom data.
public enum URLEmptyAssetProvider: URLAssetLoaderProvider {
    // swiftlint:disable:next missing_docs
    public static func asset(from input: URLInput<EmptyCustomData>, metadata: PlayerMetadata) -> Asset {
        .simple(url: input.url)
    }
}

@available(iOS 17.0, *)
@available(tvOS, unavailable)
extension URLEmptyAssetProvider: URLAssetDownloadStoreProvider {
    // swiftlint:disable:next missing_docs
    public static func asset(fileUrl: URL, customData: EmptyCustomData) -> Asset {
        .simple(url: fileUrl)
    }
}
