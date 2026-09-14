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

enum MediaAssetProvider: URLAssetLoaderProvider {
    private static func configuration(from customData: MediaCustomData) -> PlaybackConfiguration {
        .init(position: at(customData.startTime))
    }

    static func asset(from input: URLInput<MediaCustomData>, metadata: AssetMetadata<MediaCustomData>) -> Asset {
        let configuration = Self.configuration(from: metadata.customData)
        switch metadata.customData.protection {
        case .none:
            return .simple(url: input.url, configuration: configuration)
        case .token:
            return .tokenProtected(url: input.url, configuration: configuration)
        case let .fairPlay(certificateUrl: certificateUrl):
            return .encrypted(url: input.url, certificateUrl: certificateUrl, configuration: configuration)
        }
    }
}

@available(tvOS, unavailable)
extension MediaAssetProvider: URLAssetDownloadStoreProvider {
    static func asset(fileUrl: URL, customData: MediaCustomData) -> Asset {
        .simple(url: fileUrl, configuration: Self.configuration(from: customData))
    }
}
