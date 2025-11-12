//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct BasicSystemVideoView<VideoOverlay>: UIViewControllerRepresentable where VideoOverlay: View {
    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]
    let infoViewActions: [InfoViewAction]
    let videoOverlay: VideoOverlay

    func makeCoordinator() -> SystemVideoViewCoordinator {
        .init()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = false
#if os(iOS)
        controller.updatesNowPlayingInfoCenter = false
#endif
        context.coordinator.controller = controller
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
        uiViewController.setVideoOverlay(videoOverlay)
#if os(tvOS)
        uiViewController.contextualActions = contextualActions
        uiViewController.infoViewActions = infoViewActions.map { $0.toUIAction(dismissing: uiViewController) }
#endif
        context.coordinator.player = player
    }
}
