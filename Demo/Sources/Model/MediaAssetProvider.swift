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
        var configuration = PlaybackConfiguration(position: at(customData.startTime))
        if !customData.isBuffered {
            configuration.automaticallyPreservesTimeOffsetFromLive = true
            configuration.preferredForwardBufferDuration = 1
        }
        return configuration
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
        // TODO: Handle Akamai token protection and DRM encryption
        .simple(url: fileUrl, configuration: Self.configuration(from: customData))
    }
}
