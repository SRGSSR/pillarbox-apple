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
    let videoOverlay: VideoOverlay

#if os(tvOS)
    func makeCoordinator() -> AVPlayerViewControllerSpeedCoordinator {
        .init()
    }
#endif

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
        uiViewController.contextualActions = contextualActions
        context.coordinator.player = player
        context.coordinator.controller = uiViewController
#endif
    }
}
