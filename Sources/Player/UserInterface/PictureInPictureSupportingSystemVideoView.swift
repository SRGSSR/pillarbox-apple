//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
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

class AVPlayerViewControllerCoordinator {
    let player: Player
    let controller: AVPlayerViewController
    private var cancellables = Set<AnyCancellable>()

    init(player: Player, controller: AVPlayerViewController) {
        self.player = player
        self.controller = controller
        configurePlaybackSpeedPublisher()
    }

    func configurePlaybackSpeedPublisher() {
        Publishers.CombineLatest(
            player.propertiesPublisher.slice(at: \.rate),
            player.propertiesPublisher.slice(at: \.mediaType)
        )
        .sink { [weak self] _ in
            let maxRate = self?.player.playbackSpeedRange.upperBound ?? 1
            self?.controller.speeds = AVPlaybackSpeed.systemDefaultSpeeds.filter { $0.rate <= maxRate }
        }
        .store(in: &cancellables)
    }
}

// swiftlint:disable:next type_name
struct PictureInPictureSupportingSystemVideoView: UIViewControllerRepresentable {
    let player: Player
    let gravity: AVLayerVideoGravity

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: AVPlayerViewControllerCoordinator) {
        PictureInPicture.shared.system.relinquish(for: uiViewController)
    }

    func makeCoordinator() -> AVPlayerViewControllerCoordinator {
        .init(player: player, controller: PictureInPicture.shared.system.playerViewController ?? PlayerViewController())
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
    }
}
