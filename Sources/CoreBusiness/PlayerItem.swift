//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Player

public extension AVPlayerItem {
    convenience init(urn: String, environment: Environment = .production) {
        let asset = AVURLAsset(url: URLCoding.encodeUrl(fromUrn: urn))
        self.init(asset: asset, associatedDelegate: AssetResourceLoaderDelegate(), queue: .global(qos: .userInteractive))
    }
}
