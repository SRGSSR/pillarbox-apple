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
    private var forbiddenRanges: [CMTimeRange] = []
    private weak var player: Player?

    required init(configuration: Void) {}

    func enable(for player: Player) {
        self.player = player

        player.smoothCurrentTimePublisher(interval: .init(value: 1, timescale: 10), queue: .main)
            .sink { [weak self, weak player] time in
                guard let player else { return }
                self?.forbiddenRanges.forEach { forbiddenRange in
                    if forbiddenRange.containsTime(time) {
                        player.seek(at(forbiddenRange.end + CMTime(value: 1, timescale: 10)), smooth: false)
                    }
                }
            }
            .store(in: &cancellables)
    }

    func updateMetadata(with metadata: MediaComposition) {
        forbiddenRanges = metadata.mainChapter.segments
            .filter { $0.blockingReason != nil }
            .map { CMTimeRange(start: .init(value: CMTimeValue($0.markIn), timescale: 1000), end: .init(value: CMTimeValue($0.markOut), timescale: 1000)) }
            .reduce(into: []) { forbiddenRanges, range in
                forbiddenRanges.append(range)
            }
        DispatchQueue.main.async {
            self.player?.forbiddenRanges = self.forbiddenRanges
        }
    }

    func updateProperties(with properties: PlayerProperties) {
    }

    func disable() {}
}
