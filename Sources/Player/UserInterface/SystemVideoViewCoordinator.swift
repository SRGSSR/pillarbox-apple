//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import UIKit

final class SystemVideoViewCoordinator {
    var player: Player? {
        didSet {
#if os(tvOS)
            configurePlaybackSpeedPublisher(player: player, controller: controller)
#endif
        }
    }

    var controller: AVPlayerViewController? {
        didSet {
#if os(tvOS)
            configurePlaybackSpeedPublisher(player: player, controller: controller)
#endif
        }
    }

    private var cancellable: AnyCancellable?
}

@available(iOS, unavailable)
private extension SystemVideoViewCoordinator {
    private static func allowedSpeeds(from range: ClosedRange<Float>) -> Set<Float> {
        Set(
            AVPlaybackSpeed.systemDefaultSpeeds
                .map(\.rate)
                .filter { range.contains($0) }
        )
    }

    private static func speedMenuItems(
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

    func configurePlaybackSpeedPublisher(player: Player?, controller: AVPlayerViewController?) {
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
