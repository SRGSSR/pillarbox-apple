//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVKit
import Combine
import UIKit

import SwiftUI

@available(iOS, unavailable)
final class SystemVideoViewCoordinator: NSObject {
    var player: Player? {
        didSet {
            configurePlaybackSpeedPublisher(player: player, controller: controller)
        }
    }

    var controller: AVPlayerViewController? {
        didSet {
            controller?.delegate = self
            configurePlaybackSpeedPublisher(player: player, controller: controller)
        }
    }

    private var cancellable: AnyCancellable?
}

@available(iOS, unavailable)
extension SystemVideoViewCoordinator: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, shouldPresent proposal: AVContentProposal) -> Bool {
        playerViewController.contentProposalViewController = ContentProposalHostController(playerViewFrame: nil, content: Color.blue)
        return true
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, didAccept proposal: AVContentProposal) {
        player?.advanceToNext()
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, didReject proposal: AVContentProposal) {}
}

@available(iOS, unavailable)
private extension SystemVideoViewCoordinator {
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
                title: NSLocalizedString("Playback Speed", bundle: .module, comment: "Playback speed menu title"),
                image: UIImage(systemName: "speedometer"),
                options: [.singleSelection],
                children: speedActions
            )
        ]
    }
}
