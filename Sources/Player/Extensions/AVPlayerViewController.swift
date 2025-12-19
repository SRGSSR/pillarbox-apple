//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

private var kContentOverlayViewControllerKey: Void?

extension AVPlayerViewController {
    private var contentOverlayViewController: UIViewController? {
        get {
            objc_getAssociatedObject(self, &kContentOverlayViewControllerKey) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &kContentOverlayViewControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @available(iOS, unavailable)
    func updateTransportBarCustomMenuItemsIfNeeded(with items: [UIMenuElement]) {
        guard transportBarCustomMenuItems != items else { return }
        transportBarCustomMenuItems = items
    }

    @available(iOS, unavailable)
    func updateContextualActionsIfNeeded(with actions: [UIAction]) {
        guard contextualActions != actions else { return }
        contextualActions = actions
    }

    @available(iOS, unavailable)
    func updateInfoViewActionsIfNeeded(with actions: [UIAction]) {
        guard infoViewActions != actions else { return }
        infoViewActions = actions
    }

    @available(iOS, unavailable)
    func updateCustomInfoViews(with viewControllers: [UIViewController]) {
        customInfoViewControllers = viewControllers
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

    func setVideoOverlay<VideoOverlay>(_ videoOverlay: VideoOverlay) where VideoOverlay: View {
        guard let contentOverlayView else { return }
        if let hostController = contentOverlayViewController as? UIHostingController<VideoOverlay> {
            hostController.rootView = videoOverlay
        }
        else {
            let hostController = UIHostingController(rootView: videoOverlay)
            guard let hostView = hostController.view else { return }
            hostView.backgroundColor = .clear
            contentOverlayView.addSubview(hostView)
            contentOverlayViewController = hostController

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
