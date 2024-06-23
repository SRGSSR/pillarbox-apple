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
    @MainActor
    func testCannotSeekWithEmptyPlayer() {
        let player = Player()
        expect(player.canSeek(to: .zero)).to(beFalse())
    }

    @MainActor
    func testCanSeekInTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: CMTimeMultiplyByFloat64(Stream.onDemand.duration, multiplier: 0.5))).to(beTrue())
    }

    @MainActor
    func testCannotSeekInEmptyTimeRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expect(player.canSeek(to: .zero)).to(beFalse())
    }

    @MainActor
    func testCanSeekToTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.seekableTimeRange.start)).to(beTrue())
    }

    @MainActor
    func testCanSeekToTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.seekableTimeRange.end)).to(beTrue())
    }

    @MainActor
    func testCannotSeekBeforeTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: CMTime(value: -10, timescale: 1))).to(beFalse())
    }

    @MainActor
    func testCannotSeekAfterTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.canSeek(to: player.seekableTimeRange.end + CMTime(value: 1, timescale: 1))).to(beFalse())
    }
}
