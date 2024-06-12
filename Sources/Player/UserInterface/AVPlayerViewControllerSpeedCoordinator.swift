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
    var player: Player? {
        didSet {
            configurePlaybackSpeedPublisher(player: player, controller: controller)
        }
    }

    var controller: AVPlayerViewController? {
        didSet {
            configurePlaybackSpeedPublisher(player: player, controller: controller)
        }
    }

    private var cancellable: AnyCancellable?

    private func configurePlaybackSpeedPublisher(player: Player?, controller: AVPlayerViewController?) {
        guard let player, let controller else {
            cancellable = nil
            return
        }
        cancellable = player.playbackSpeedPublisher()
            .map { speed in
                guard let range = speed.range, range != 1...1 else { return [] }
                return Self.speedMenuItems(for: player, range: range, speed: speed.effectiveValue)
            }
            .receiveOnMainThread()
            .assign(to: \.transportBarCustomMenuItems, on: controller)
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
                title: String(localized: "Playback Speed", bundle: .module, comment: "Playback setting menu title"),
                image: UIImage(systemName: "speedometer"),
                options: [.singleSelection],
                children: speedActions
            )
        ]
    }
}
