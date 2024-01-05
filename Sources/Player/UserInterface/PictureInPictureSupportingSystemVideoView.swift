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
#endif

        init(player: Player, controller: AVPlayerViewController) {
            self.player = player
            self.controller = controller

#if os(tvOS)
            configurePlaybackSpeedPublisher(player: player, controller: controller)
#endif
        }

#if os(tvOS)
        private func configurePlaybackSpeedPublisher(player: Player, controller: AVPlayerViewController) {
            Publishers.CombineLatest(
                player.playbackSpeedUpdatePublisher(),
                player.$_playbackSpeed
            )
            .receiveOnMainThread()
            .sink { speedUpdate, speed in
                if case .range(1...1) = speedUpdate {
                    controller.transportBarCustomMenuItems = []
                }
                else if case let .range(range) = speedUpdate, let range {
                    Self.configureSpeeds(for: player, controller: controller, range: range, speed: speed.effectiveValue)
                }
            }
            .store(in: &cancellables)
        }

        private static func allowedSpeeds(from range: ClosedRange<Float>) -> Set<Float> {
            Set(
                AVPlaybackSpeed.systemDefaultSpeeds
                    .map(\.rate)
                    .filter { rate in
                        range.lowerBound <= rate && rate <= range.upperBound
                    }
            )
        }

        private static func configureSpeeds(
            for player: Player,
            controller: AVPlayerViewController,
            range: ClosedRange<Float>,
            speed: Float
        ) {
            let speedActions = allowedSpeeds(from: range).sorted().map { allowedSpeed in
                UIAction(title: String(format: "%g×", allowedSpeed), state: speed == allowedSpeed ? .on : .off) { [weak player] action in
                    player?.playbackSpeed.wrappedValue = allowedSpeed
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
