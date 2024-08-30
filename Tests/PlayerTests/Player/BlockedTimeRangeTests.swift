//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

private let kBlockedTimeRange = CMTimeRange(start: .init(value: 20, timescale: 1), end: .init(value: 60, timescale: 1))
private let kOverlappingBlockedTimeRange = CMTimeRange(start: .init(value: 50, timescale: 1), end: .init(value: 100, timescale: 1))
private let kNestedBlockedTimeRange = CMTimeRange(start: .init(value: 30, timescale: 1), end: .init(value: 50, timescale: 1))

private struct MetadataWithBlockedTimeRange: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(timeRanges: [
            .init(kind: .blocked, start: kBlockedTimeRange.start, end: kBlockedTimeRange.end)
        ])
    }
}

private struct MetadataWithOverlappingBlockedTimeRanges: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(timeRanges: [
            .init(kind: .blocked, start: kBlockedTimeRange.start, end: kBlockedTimeRange.end),
            .init(kind: .blocked, start: kOverlappingBlockedTimeRange.start, end: kOverlappingBlockedTimeRange.end)
        ])
    }
}

private struct MetadataWithNestedBlockedTimeRanges: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(timeRanges: [
            .init(kind: .blocked, start: kBlockedTimeRange.start, end: kBlockedTimeRange.end),
            .init(kind: .blocked, start: kNestedBlockedTimeRange.start, end: kNestedBlockedTimeRange.end)
        ])
    }
}

final class BlockedTimeRangeTests: TestCase {
    func testSeekInBlockedTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MetadataWithBlockedTimeRange()))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.seek(at(.init(value: 30, timescale: 1)))
        expect(kBlockedTimeRange.containsTime(player.time())).toNever(beTrue(), until: .seconds(2))
        expect(player.time()).to(equal(kBlockedTimeRange.end))
    }

    func testSeekInOverlappingBlockedTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MetadataWithOverlappingBlockedTimeRanges()))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.seek(at(.init(value: 30, timescale: 1)))
        expect(kOverlappingBlockedTimeRange.containsTime(player.time())).toNever(beTrue(), until: .seconds(2))
        expect(player.time()).to(equal(kOverlappingBlockedTimeRange.end))
    }

    func testSeekInNestedBlockedTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MetadataWithNestedBlockedTimeRanges()))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.seek(at(.init(value: 40, timescale: 1)))
        expect(kNestedBlockedTimeRange.containsTime(player.time())).toNever(beTrue(), until: .seconds(2))
        expect(player.time()).to(equal(kBlockedTimeRange.end))
    }

    func testBlockedTimeRangeTraversal() {
        let configuration = PlayerItemConfiguration(position: at(.init(value: 29, timescale: 1)))
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MetadataWithBlockedTimeRange(), configuration: configuration))
        player.play()
        expect(player.time()).toEventually(beGreaterThan(kBlockedTimeRange.end))
    }

    func testOnDemandStartInBlockedTimeRange() {
        let configuration = PlayerItemConfiguration(position: at(.init(value: 30, timescale: 1)))
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MetadataWithBlockedTimeRange(), configuration: configuration))
        expect(player.time()).toEventually(equal(kBlockedTimeRange.end))
    }
}
