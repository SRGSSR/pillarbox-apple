//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

extension AVPlayerViewController {
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

    func setVideoOverlay<VideoOverlay>(_ videoOverlay: VideoOverlay) where VideoOverlay: View {
        guard let contentOverlayView else { return }
        if let hostController = children.compactMap({ $0 as? UIHostingController<VideoOverlay> }).first {
            hostController.rootView = videoOverlay
        }
        else {
            let hostController = UIHostingController(rootView: videoOverlay)
            guard let hostView = hostController.view else { return }
            hostView.backgroundColor = .clear
            addChild(hostController)
            contentOverlayView.addSubview(hostView)
            hostController.didMove(toParent: self)

            hostView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostView.topAnchor.constraint(equalTo: contentOverlayView.topAnchor),
                hostView.bottomAnchor.constraint(equalTo: contentOverlayView.bottomAnchor),
                hostView.leadingAnchor.constraint(equalTo: contentOverlayView.leadingAnchor),
                hostView.trailingAnchor.constraint(equalTo: contentOverlayView.trailingAnchor)
            ])
        }
    }
}
