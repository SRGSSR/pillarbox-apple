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

private struct MockMetadata: AssetMetadata {
    var playerMetadata: PlayerMetadata {
        .init(timeRanges: [
            .init(kind: .blocked, start: .init(value: 20, timescale: 1), end: .init(value: 60, timescale: 1))
        ])
    }
}

final class SeekTests: TestCase {
    @MainActor
    func testSeekWhenEmpty() async {
        let player = Player()
        await waitUntil { done in
            player.seek(near(.zero)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSeekInTimeRange() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await waitUntil { done in
            player.seek(near(CMTimeMultiplyByFloat64(Stream.onDemand.duration, multiplier: 0.5))) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSeekInEmptyTimeRange() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        await waitUntil { done in
            player.seek(near(.zero)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSeekToTimeRangeStart() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await waitUntil { done in
            player.seek(near(player.seekableTimeRange.start)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSeekToTimeRangeEnd() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await waitUntil { done in
            player.seek(near(player.seekableTimeRange.end)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSeekBeforeTimeRangeStart() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await waitUntil { done in
            player.seek(near(CMTime(value: -10, timescale: 1))) { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(.zero))
                done()
            }
        }
    }

    @MainActor
    func testSeekAfterTimeRangeEnd() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        await waitUntil { done in
            player.seek(near(player.seekableTimeRange.end + CMTime(value: 10, timescale: 1))) { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(player.seekableTimeRange.end, by: beClose(within: 1)))
                done()
            }
        }
    }

    @MainActor
    func testTimesDuringSeekBeforeTimeRangeStart() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.play()
        player.seek(near(CMTime(value: -10, timescale: 1)))
        await expect(player.time()).toAlways(beGreaterThanOrEqualTo(player.seekableTimeRange.start), until: .seconds(1))
    }

    @MainActor
    func testOnDemandStartAtTime() async {
        let configuration = PlaybackConfiguration(position: at(.init(value: 10, timescale: 1)))
        let player = Player(item: .simple(url: Stream.onDemand.url, configuration: configuration))
        await expect(player.time().seconds).toEventually(equal(10))
    }

    @MainActor
    func testDvrStartAtTime() async {
        let configuration = PlaybackConfiguration(position: at(.init(value: 10, timescale: 1)))
        let player = Player(item: .simple(url: Stream.dvr.url, configuration: configuration))
        await expect(player.time().seconds).toEventually(equal(10))
    }
}
