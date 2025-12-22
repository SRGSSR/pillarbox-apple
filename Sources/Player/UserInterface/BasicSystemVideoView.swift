//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct BasicSystemVideoView<VideoOverlay>: UIViewControllerRepresentable where VideoOverlay: View {
    let player: Player
    let videoOverlay: VideoOverlay
    let gravity: AVLayerVideoGravity

    let transportBarContent: TransportBarContent
    let contextualActionsContent: ContextualActionsContent
    let infoViewActionsContent: InfoViewActionsContent
    let customInfoViewsContent: CustomInfoViewsContent

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = false
#if os(iOS)
        controller.updatesNowPlayingInfoCenter = false
#endif
        return controller
    }

    func makeCoordinator() -> CustomInfoViewsCoordinator {
        .init()
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
        uiViewController.setVideoOverlay(videoOverlay)
#if os(tvOS)
        uiViewController.updateTransportBarCustomMenuItemsIfNeeded(with: transportBarContent.toMenuElements())
        uiViewController.updateContextualActionsIfNeeded(with: contextualActionsContent.toActions())
        uiViewController.updateInfoViewActionsIfNeeded(with: infoViewActionsContent.toActions(dismissing: uiViewController))
        uiViewController.updateCustomInfoViews(with: customInfoViewsContent.toUIViewControllers(using: context.coordinator))
#endif
    }
}
