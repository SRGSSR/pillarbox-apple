//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxStreams

private let kBlockedTimeRange = CMTimeRange(start: .init(value: 20, timescale: 1), end: .init(value: 60, timescale: 1))

private struct MockMetadata: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(timeRanges: [
            .init(kind: .blocked, start: kBlockedTimeRange.start, end: kBlockedTimeRange.end)
        ])
    }
}

final class BlockedTimeRangeTests: TestCase {
    func testSeekInBlockedTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MockMetadata()))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.seek(at(.init(value: 30, timescale: 1)))
        expect(kBlockedTimeRange.containsTime(player.time)).toNever(beTrue(), until: .seconds(2))
        expect(player.time).to(equal(kBlockedTimeRange.end))
    }

    func testBlockedTimeRangeTraversal() {
        let configuration = PlayerItemConfiguration(position: at(.init(value: 29, timescale: 1)))
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MockMetadata(), configuration: configuration))
        player.play()
        expect(player.time).toEventually(beGreaterThan(kBlockedTimeRange.end))
    }

    func testOnDemandStartInBlockedTimeRange() {
        let configuration = PlayerItemConfiguration(position: at(.init(value: 30, timescale: 1)))
        let player = Player(item: .simple(url: Stream.onDemand.url, metadata: MockMetadata(), configuration: configuration))
        expect(player.time).toEventually(equal(kBlockedTimeRange.end))
    }
}
