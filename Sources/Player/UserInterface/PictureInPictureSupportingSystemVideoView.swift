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
        if isMovingToParent || isBeingPresented {
            PictureInPicture.shared.system.stop()
        }
    }
}

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = PictureInPicture.shared.system.playerViewController ?? PlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        PictureInPicture.shared.system.acquire(for: controller)
        PictureInPicture.shared.mode = .system
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        PictureInPicture.shared.system.update(with: player.queuePlayer)
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
    }
}
