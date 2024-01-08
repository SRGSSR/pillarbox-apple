//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import UIKit

@available(iOS, unavailable)
final class AVPlayerViewControllerSpeedCoordinator {
    let player: Player
    let controller: AVPlayerViewController
    private var cancellables = Set<AnyCancellable>()

    init(player: Player, controller: AVPlayerViewController) {
        self.player = player
        self.controller = controller
        configurePlaybackSpeedPublisher(player: player, controller: controller)
    }

    private func configurePlaybackSpeedPublisher(player: Player, controller: AVPlayerViewController) {
        player.playbackSpeedPublisher()
            .receiveOnMainThread()
            .sink { speed in
                guard let range = speed.range else { return }
                if range == 1...1 {
                    controller.transportBarCustomMenuItems = []
                }
                else {
                    Self.configureSpeeds(for: player, controller: controller, range: range, speed: speed.effectiveValue)
                }
            }
            .store(in: &cancellables)
    }
}

@available(iOS, unavailable)
private extension AVPlayerViewControllerSpeedCoordinator {
    static func allowedSpeeds(from range: ClosedRange<Float>) -> Set<Float> {
        Set(
            AVPlaybackSpeed.systemDefaultSpeeds
                .map(\.rate)
                .filter { range.contains($0) }
        )
    }

    static func configureSpeeds(
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
}
