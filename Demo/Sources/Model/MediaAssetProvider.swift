//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@_spi(CoreBusinessPrivate)
import PillarboxCoreBusiness

@_spi(DownloaderPrivate)
import PillarboxPlayer

enum MediaAssetProvider: URLOnlineAssetProvider {
    static func asset(from input: URLInput<MediaProvider>, metadata: AssetMetadata<MediaProvider>) -> Asset {
        // TODO: Configuration
        switch metadata.customData {
        case .simple:
            return .simple(url: input.url)
        case .tokenProtected:
            return .tokenProtected(url: input.url, configuration: .default)
        case let .encrypted(certificateUrl: certificateUrl):
            return .encrypted(url: input.url, certificateUrl: certificateUrl, configuration: .default)
        }
    }
}

@available(tvOS, unavailable)
extension MediaAssetProvider: URLOfflineAssetProvider {
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: MediaProvider) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
