//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum MediaAssetProvider: URLOfflineAssetProvider {
    static func asset(from input: URLInput<MediaCustomData>, metadata: AssetMetadata<MediaCustomData>) -> Asset {
        // TODO: Return the correct asset
        .simple(url: input.url)
    }

    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: MediaCustomData) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
