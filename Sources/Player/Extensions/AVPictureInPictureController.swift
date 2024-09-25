//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

extension AVPictureInPictureController {
    var parentPlayer: Player? {
        contentSource?.playerLayer?.player?.parent
    }
}
