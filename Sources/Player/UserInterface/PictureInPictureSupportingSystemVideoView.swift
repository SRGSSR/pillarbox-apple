//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

private class PlayerViewController: AVPlayerViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // We can use fine-grained presentation information to avoid stopping Picture in Picture when enabled
        // from maximized layout.
        if isMovingToParent || isBeingPresented {
            PictureInPicture.shared.system.stop()
        }
    }
}

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

#if os(iOS)
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }
#else
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: AVPlayerViewControllerSpeedCoordinator) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

    func makeCoordinator() -> AVPlayerViewControllerSpeedCoordinator {
        .init(
            player: player,
            controller: PictureInPicture.shared.system.playerViewController ?? PlayerViewController()
        )
    }
#endif

    func makeUIViewController(context: Context) -> AVPlayerViewController {
#if os(iOS)
        let controller = PictureInPicture.shared.system.playerViewController ?? PlayerViewController()
#else
        let controller = context.coordinator.controller
#endif
        controller.allowsPictureInPicturePlayback = true
        PictureInPicture.shared.system.acquire(for: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
    }
}
