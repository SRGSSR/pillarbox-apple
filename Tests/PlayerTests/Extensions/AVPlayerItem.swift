//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayerItem {
    var url: URL? {
        (asset as? AVURLAsset)?.url
    }
}
