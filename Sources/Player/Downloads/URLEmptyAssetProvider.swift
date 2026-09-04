//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Combine
import Foundation

@available(iOS 17.0, *)
@available(tvOS, unavailable)
@_spi(DownloaderPrivate)
public enum URLEmptyAssetProvider: URLOfflineAssetProvider {
    public static func asset(from input: URLInput<EmptyCustomData>, metadata: PlayerMetadata) -> Asset {
        .simple(url: input.url)
    }

    public static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: EmptyCustomData) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}

// swiftlint:enable missing_docs
