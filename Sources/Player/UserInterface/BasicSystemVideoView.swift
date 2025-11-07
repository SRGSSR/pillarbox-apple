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
    let infoViewActions: [InfoViewActions]
    let videoOverlay: VideoOverlay

    func makeCoordinator() -> SystemVideoViewCoordinator {
        .init()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = false
#if os(iOS)
        controller.updatesNowPlayingInfoCenter = false
#else
        context.coordinator.systemInfoViewActions = controller.infoViewActions
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
        if !infoViewActions.isEmpty {
            uiViewController.infoViewActions = infoViewActions.toUIActions(using: context.coordinator.systemInfoViewActions)
        }
#endif
        context.coordinator.player = player
    }
}
