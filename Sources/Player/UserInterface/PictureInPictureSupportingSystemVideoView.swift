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
#if os(tvOS)
    typealias Coordinator = SystemVideoViewCoordinator
#else
    typealias Coordinator = Void
#endif

    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

#if os(tvOS)
    func makeCoordinator() -> Coordinator {
        .init()
    }
#endif

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = PictureInPicture.shared.system.playerViewController ?? PlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        PictureInPicture.shared.system.acquire(for: controller)
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
