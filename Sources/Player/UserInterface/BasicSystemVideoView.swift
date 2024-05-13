//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

struct BasicSystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]

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
#if os(tvOS)
        uiViewController.contextualActions = contextualActions
        context.coordinator.player = player
        context.coordinator.controller = uiViewController
#endif
    }
}
