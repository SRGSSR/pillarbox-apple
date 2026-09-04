//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum MediaAssetProvider: URLOnlineAssetProvider {
    static func asset(from input: URLInput<MediaProvider>, metadata: AssetMetadata<MediaProvider>) -> Asset {
        // TODO: Return the correct asset
        .simple(url: input.url)
    }
}

@available(tvOS, unavailable)
extension MediaAssetProvider: URLOfflineAssetProvider {
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: MediaProvider) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
