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

    func duplicate() -> Self {
        let duplicate = Self()
        duplicate.player = player
        duplicate.showsPlaybackControls = showsPlaybackControls
        duplicate.videoGravity = videoGravity
        duplicate.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        duplicate.requiresLinearPlayback = requiresLinearPlayback
        duplicate.pixelBufferAttributes = pixelBufferAttributes
        duplicate.delegate = delegate
        duplicate.speeds = speeds
#if os(iOS)
        duplicate.showsTimecodes = showsTimecodes
        duplicate.allowsVideoFrameAnalysis = allowsVideoFrameAnalysis
        duplicate.canStartPictureInPictureAutomaticallyFromInline = canStartPictureInPictureAutomaticallyFromInline
        duplicate.updatesNowPlayingInfoCenter = updatesNowPlayingInfoCenter
        duplicate.entersFullScreenWhenPlaybackBegins = entersFullScreenWhenPlaybackBegins
        duplicate.exitsFullScreenWhenPlaybackEnds = exitsFullScreenWhenPlaybackEnds
#endif
        return duplicate
    }
}
