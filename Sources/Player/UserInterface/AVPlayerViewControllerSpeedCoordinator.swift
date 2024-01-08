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
                if let range = speed.range, range != 1...1 {
                    controller.transportBarCustomMenuItems = Self.speedMenuItems(for: player, range: range, speed: speed.effectiveValue)
                }
                else {
                    controller.transportBarCustomMenuItems = []
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

    static func speedMenuItems(
        for player: Player,
        range: ClosedRange<Float>,
        speed: Float
    ) -> [UIMenuElement] {
        let speedActions = allowedSpeeds(from: range).sorted().map { allowedSpeed in
            UIAction(title: String(format: "%g×", allowedSpeed), state: speed == allowedSpeed ? .on : .off) { [weak player] action in
                player?.playbackSpeed.wrappedValue = allowedSpeed
                action.state = .on
            }
        }
        return [
            UIMenu(
                title: "Playback Speed",
                image: UIImage(systemName: "speedometer"),
                options: [.singleSelection],
                children: speedActions
            )
        ]
    }
}
