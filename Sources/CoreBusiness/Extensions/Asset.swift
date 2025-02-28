//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

extension Asset {
    static func tokenProtected(url: URL, metadata: M, configuration: PlaybackConfiguration) -> Self {
        let id = UUID()
        return .custom(
            url: AkamaiURLCoding.encodeUrl(url, id: id),
            delegate: AkamaiResourceLoaderDelegate(id: id),
            metadata: metadata,
            configuration: configuration
        )
    }

    static func encrypted(url: URL, certificateUrl: URL, metadata: M, configuration: PlaybackConfiguration) -> Self {
        .encrypted(
            url: url,
            delegate: ContentKeySessionDelegate(certificateUrl: certificateUrl),
            metadata: metadata,
            configuration: configuration
        )
    }
}
