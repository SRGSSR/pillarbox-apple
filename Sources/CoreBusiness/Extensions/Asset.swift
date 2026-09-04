//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable missing_docs

import Foundation
import PillarboxPlayer

@_spi(CoreBusinessPrivate)
public extension Asset {
    static func tokenProtected(url: URL, configuration: PlaybackConfiguration) -> Self {
        let id = UUID()
        return .custom(
            url: Akamai.encodeUrl(url, id: id),
            delegate: AkamaiResourceLoaderDelegate(id: id),
            configuration: configuration
        )
    }

    static func encrypted(url: URL, certificateUrl: URL, configuration: PlaybackConfiguration) -> Self {
        .encrypted(
            url: url,
            delegate: IrdetoContentKeySessionDelegate(certificateUrl: certificateUrl),
            configuration: configuration
        )
    }
}

// swiftlint:enable missing_docs
