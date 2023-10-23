//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import Player
import SwiftUI

final class SystemPictureInPicture: NSObject, AVPlayerViewControllerDelegate {
    static let shared = SystemPictureInPicture()

    private var window: UIWindow?
    private var cancellables = Set<AnyCancellable>()

    func playerViewControllerDidStartPictureInPicture(_ playerViewController: AVPlayerViewController) {
        window = playerViewController.view.window
        playerViewController.dismiss(animated: true)
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        if let rootViewController = window?.rootViewController {
            rootViewController.present(playerViewController, animated: true) {
                completionHandler(true)
            }
        }
        else {
            completionHandler(true)
        }
    }
}

struct SystemPipPlayerView: UIViewControllerRepresentable {
    let player: Player

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.allowsPictureInPicturePlayback = true
        controller.delegate = SystemPictureInPicture.shared
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
    }
}
