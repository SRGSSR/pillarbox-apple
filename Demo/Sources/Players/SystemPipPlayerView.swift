//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Player
import SwiftUI

struct SystemPipPlayerView: UIViewControllerRepresentable {
    let player: Player

    class Coordinator: NSObject, AVPlayerViewControllerDelegate {

    }

    func makeCoordinator() -> Coordinator {
        .init()
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
    }
}
