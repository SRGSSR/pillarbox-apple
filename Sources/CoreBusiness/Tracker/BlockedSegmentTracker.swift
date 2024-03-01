//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia
import PillarboxPlayer

class BlockedSegmentTracker: PlayerItemTracker {
    private var cancellables = Set<AnyCancellable>()
    private var forbiddenRanges: [ClosedRange<TimeInterval>] = []
    private weak var player: Player?

    required init(configuration: Void) {}

    func enable(for player: Player) {
        self.player = player

        Timer.publish(every: 1 / 1_000, on: .current, in: .common)
            .autoconnect()
            .sink { [weak self, weak player] _ in
                guard let player else { return }
                self?.forbiddenRanges.forEach { forbiddenRange in
                    if forbiddenRange.contains(player.time.seconds) {
                        player.seek(after(.init(value: CMTimeValue(forbiddenRange.upperBound + 1), timescale: 1)), smooth: false)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func updateMetadata(with metadata: MediaComposition) {
        forbiddenRanges = metadata.mainChapter.segments
            .filter { $0.blockingReason != nil }
            .map { TimeInterval($0.markIn / 1000)...TimeInterval($0.markOut / 1000) }
            .reduce(into: []) { forbiddenRanges, range in
                forbiddenRanges.append(range)
            }
        player?.forbiddenRanges = forbiddenRanges
    }

    func updateProperties(with properties: PlayerProperties) {}

    func disable() {}
}
