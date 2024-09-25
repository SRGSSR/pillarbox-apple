//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

extension AVPlayerViewController {
    var parentPlayer: Player? {
        player?.parent
    }

    func stopPictureInPicture() {
        guard allowsPictureInPicturePlayback else { return }
        allowsPictureInPicturePlayback = false
        allowsPictureInPicturePlayback = true
    }
}
