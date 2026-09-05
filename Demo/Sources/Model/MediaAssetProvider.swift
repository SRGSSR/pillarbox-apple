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
    static func asset(from input: URLInput<Protection>, metadata: AssetMetadata<Protection>) -> Asset {
        // TODO: Configuration
        switch metadata.customData {
        case .none:
            return .simple(url: input.url)
        case .token:
            return .tokenProtected(url: input.url, configuration: .default)
        case let .fairPlay(certificateUrl: certificateUrl):
            return .encrypted(url: input.url, certificateUrl: certificateUrl, configuration: .default)
        }
    }
}

@available(tvOS, unavailable)
extension MediaAssetProvider: URLOfflineAssetProvider {
    static func asset(fileUrl: URL, configuration: PlaybackConfiguration, customData: Protection) -> Asset {
        .simple(url: fileUrl, configuration: configuration)
    }
}
