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
    }
}

extension PictureInPictureSupportingSystemVideoView {
    class Coordinator {
        let player: Player
        let controller: AVPlayerViewController
#if os(tvOS)
        private var cancellables = Set<AnyCancellable>()

        private var allowedSpeeds: Set<Float> {
            let range = player.playbackSpeedRange
            return Set(
                AVPlaybackSpeed.systemDefaultSpeeds
                    .map(\.rate)
                    .filter { rate in
                        range.lowerBound <= rate && rate <= range.upperBound
                    }
            )
        }
#endif

        init(player: Player, controller: AVPlayerViewController) {
            self.player = player
            self.controller = controller

#if os(tvOS)
            Publishers.CombineLatest(
                player.propertiesPublisher.slice(at: \.streamType),
                player.playbackSpeedUpdatePublisher()
            )
            .receiveOnMainThread()
            .sink { [weak self] _ in
                if self?.player.playbackSpeedRange == 1...1 {
                    controller.transportBarCustomMenuItems = []
                }
                else {
                    self?.configureSpeeds(controller: controller)
                }
            }
            .store(in: &cancellables)
#endif
        }

#if os(tvOS)
        func configureSpeeds(controller: AVPlayerViewController) {
            let speedActions = allowedSpeeds.sorted().map { speed in
                let isSelected = self.player.playbackState == .paused ? self.player.effectivePlaybackSpeed == speed : self.player.systemPlayer.rate == speed
                return UIAction(title: String(format: "%g×", speed), state: isSelected ? .on : .off) { [weak self] action in
                    self?.player.playbackSpeed.wrappedValue = speed
                    action.state = .on
                }
            }

            controller.transportBarCustomMenuItems = [
                UIMenu(
                    title: "Playback Speed",
                    image: UIImage(systemName: "speedometer"),
                    options: [.singleSelection],
                    children: speedActions
                )
            ]
        }
#endif
    }
}
