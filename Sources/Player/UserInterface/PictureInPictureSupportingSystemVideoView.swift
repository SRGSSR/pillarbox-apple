//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView<VideoOverlay>: UIViewControllerRepresentable where VideoOverlay: View {
    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]
    let videoOverlay: VideoOverlay

    static func dismantleUIViewController(_ uiViewController: PictureInPictureHostViewController, coordinator: SystemVideoViewCoordinator) {
        PictureInPicture.shared.system.dismantleHostViewController(uiViewController)
    }

    func makeCoordinator() -> SystemVideoViewCoordinator {
        .init()
    }

    func makeUIViewController(context: Context) -> PictureInPictureHostViewController {
        let controller = PictureInPicture.shared.system.makeHostViewController(for: player)
        context.coordinator.controller = controller.playerViewController
        return controller
    }

    func updateUIViewController(_ uiViewController: PictureInPictureHostViewController, context: Context) {
        uiViewController.playerViewController?.player = player.systemPlayer
        uiViewController.playerViewController?.videoGravity = gravity
        uiViewController.playerViewController?.setVideoOverlay(videoOverlay)
#if os(tvOS)
        uiViewController.playerViewController?.contextualActions = contextualActions
#endif
        context.coordinator.player = player
    }
}
