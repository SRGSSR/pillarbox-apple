//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import SwiftUI

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = PictureInPicture.shared.system.playerViewController ?? AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        PictureInPicture.shared.system.acquire(for: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
    }
}
