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
    typealias Coordinator = AVPlayerViewControllerSpeedCoordinator
#else
    typealias Coordinator = Void
#endif

    let player: Player
    let gravity: AVLayerVideoGravity
    let contextualActions: [UIAction]

    static func dismantleUIViewController(_ uiViewController: PictureInPictureHostViewController, coordinator: Coordinator) {
        PictureInPicture.shared.system.dismantleHostViewController(uiViewController)
    }

#if os(tvOS)
    func makeCoordinator() -> Coordinator {
        .init()
    }
#endif

    func makeUIViewController(context: Context) -> PictureInPictureHostViewController {
        PictureInPicture.shared.system.makeHostViewController(for: player)
    }

    func updateUIViewController(_ uiViewController: PictureInPictureHostViewController, context: Context) {
        uiViewController.viewController?.player = player.systemPlayer
        uiViewController.viewController?.videoGravity = gravity
#if os(tvOS)
        uiViewController.viewController?.contextualActions = contextualActions
        context.coordinator.player = player
        context.coordinator.controller = uiViewController.viewController
#endif
    }
}
