//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

@_spi(CoreBusinessPrivate)
public extension Asset {
    /// Returns an SRG SSR Akamai token-protected asset from a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    static func tokenProtected(url: URL, configuration: PlaybackConfiguration = .default) -> Self {
        let id = UUID()
        return .custom(
            url: Akamai.encodeUrl(url, id: id),
            delegate: AkamaiResourceLoaderDelegate(id: id),
            configuration: configuration
        )
    }

    /// Returns an SRG SSR FairPlay-protected asset from a URL.
    ///
    /// - Parameters:
    ///   - url: The URL to be played.
    ///   - certificateUrl: The URL where the FairPlay certificate must be downloaded.
    ///   - configuration: The configuration to apply to the asset.
    /// - Returns: The asset.
    static func encrypted(url: URL, certificateUrl: URL, configuration: PlaybackConfiguration = .default) -> Self {
        .encrypted(
            url: url,
            delegate: IrdetoContentKeySessionDelegate(certificateUrl: certificateUrl),
            configuration: configuration
        )
    }
}
