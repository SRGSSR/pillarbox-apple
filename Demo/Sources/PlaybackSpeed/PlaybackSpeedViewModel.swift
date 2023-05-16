//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Player

class PlaybackSpeedViewModel: ObservableObject {
    let playbackSpeeds: [Double] = [0.5, 1, 1.25, 1.5, 2]
    private(set) var playbackSpeed: Double = 1
    private(set) var player: Player?
    private var cancellables = Set<AnyCancellable>()

    func bind(_ player: Player) {
        self.player = player
        Publishers.CombineLatest(player.$currentIndex, player.$playbackState)
            .filter { $1 == .playing }
            .sink { [weak self] _, _ in
                guard let self else { return }
                tryToApplyPlaybackSpeed()
            }
            .store(in: &cancellables)
    }

    func updateSpeed(_ speed: Double) {
        playbackSpeed = speed
        player?.playbackSpeed = Float(speed)
    }

    private func tryToApplyPlaybackSpeed() {
        guard player?.playbackSpeed != Float(playbackSpeed) else { return }
        player?.playbackSpeed = Float(playbackSpeed)
    }
}
