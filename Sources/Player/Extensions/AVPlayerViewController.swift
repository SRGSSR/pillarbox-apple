//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit

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

    func addOverlayViewController(_ overlayViewController: UIViewController) {
        removeOverlayViewControllers()
        guard let contentOverlayView, let overlayView = overlayViewController.view else { return }
        addChild(overlayViewController)
        contentOverlayView.addSubview(overlayView)
        overlayViewController.didMove(toParent: self)

        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: contentOverlayView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentOverlayView.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentOverlayView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentOverlayView.trailingAnchor)
        ])
    }

    private func removeOverlayViewControllers() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }
}
