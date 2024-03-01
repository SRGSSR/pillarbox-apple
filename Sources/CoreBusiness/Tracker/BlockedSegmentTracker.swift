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

        Publishers.CombineLatest(
            player.periodicTimePublisher(forInterval: CMTime(value: 1, timescale: 1)),
            player.propertiesPublisher.slice(at: \.isBusy)
        )
        .sink { [weak self, weak player] _, _ in
            guard let player else { return }
            self?.forbiddenRanges.forEach { forbiddenRange in
                if forbiddenRange.contains(player.time.seconds) {
                    player.seek(at(.init(value: CMTimeValue(forbiddenRange.upperBound), timescale: 1)))
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
        let metadataItem = AVMutableMetadataItem()
        metadataItem.identifier = AVMutableMetadataItem.identifier(
            forKey: "forbidden-time-ranges",
            keySpace: AVMetadataKeySpace(rawValue: "ch.srgssr.pillarbox")
        )
        // swiftlint:disable:next legacy_objc_type
        metadataItem.value = forbiddenRanges as NSArray
        self.player?.systemPlayer.currentItem?.externalMetadata.append(metadataItem)
    }

    func updateProperties(with properties: PlayerProperties) {}

    func disable() {}
}
