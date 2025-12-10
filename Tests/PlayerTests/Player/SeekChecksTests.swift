//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class SeekChecksTests: TestCase {
    func testCannotSeekWithEmptyPlayer() {
        let player = Player()
        expect(player.canSeek(to: .zero)).to(beFalse())
    }

    @MainActor
    func testCanSeekInTimeRange() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: CMTimeMultiplyByFloat64(Stream.onDemand.duration, multiplier: 0.5))).to(beTrue())
    }

    @MainActor
    func testCannotSeekInEmptyTimeRange() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        expect(player.canSeek(to: .zero)).to(beFalse())
    }

    @MainActor
    func testCanSeekToTimeRangeStart() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.seekableTimeRange.start)).to(beTrue())
    }

    @MainActor
    func testCanSeekToTimeRangeEnd() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.seekableTimeRange.end)).to(beTrue())
    }

    @MainActor
    func testCannotSeekBeforeTimeRangeStart() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: CMTime(value: -10, timescale: 1))).to(beFalse())
    }

    @MainActor
    func testCannotSeekAfterTimeRangeEnd() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.seekableTimeRange.end + CMTime(value: 1, timescale: 1))).to(beFalse())
    }
}
