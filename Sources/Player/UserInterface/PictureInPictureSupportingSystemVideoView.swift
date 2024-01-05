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

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

    func makeCoordinator() -> Coordinator {
        let controller = PictureInPicture.shared.system.playerViewController ?? PlayerViewController()
        return Coordinator(player: player, controller: controller)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = context.coordinator.controller
        controller.allowsPictureInPicturePlayback = true
        PictureInPicture.shared.system.acquire(for: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player.systemPlayer
        uiViewController.videoGravity = gravity
#if os(tvOS)
        context.coordinator.configureSpeeds(controller: uiViewController)
#endif
    }
}

extension PictureInPictureSupportingSystemVideoView {
    class Coordinator {
        let player: Player
        let controller: AVPlayerViewController

        init(player: Player, controller: AVPlayerViewController) {
            self.player = player
            self.controller = controller
        }

        @available(iOS, unavailable)
        func configureSpeeds(controller: AVPlayerViewController) {
            let speedActions = AVPlaybackSpeed.systemDefaultSpeeds.map(\.rate).map { [weak self] speed in
                UIAction(title: String(format: "%g×", speed), state: self?.player.effectivePlaybackSpeed == speed ? .on : .off) { action in
                    self?.player.setDesiredPlaybackSpeed(speed)
                    action.state = .on
                }
            }

            controller.transportBarCustomMenuItems = [
                UIMenu(
                    title: "Speed",
                    image: UIImage(systemName: "speedometer"),
                    options: [.singleSelection],
                    children: speedActions
                )
            ]
        }
    }
}
