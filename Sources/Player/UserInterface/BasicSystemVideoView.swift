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
    let contextualActionsContent: SystemVideoViewActionsContent
    let infoViewActionsContent: SystemVideoViewActionsContent

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = false
#if os(iOS)
        controller.updatesNowPlayingInfoCenter = false
#endif
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
        uiViewController.setVideoOverlay(videoOverlay)
#if os(tvOS)
        uiViewController.updateTransportBarCustomMenuItemsIfNeeded(with: transportBarContent.toMenuElements())
        uiViewController.updateContextualActionsIfNeeded(with: contextualActionsContent.contextualActions())
        uiViewController.updateInfoViewActionsIfNeeded(with: infoViewActionsContent.infoViewActions(dismissing: uiViewController))
#endif
    }
}
