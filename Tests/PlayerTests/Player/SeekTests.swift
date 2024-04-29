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
    func testSeekWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.seek(near(.zero)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekInTimeRange() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(near(CMTimeMultiplyByFloat64(Stream.onDemand.duration, multiplier: 0.5))) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekInEmptyTimeRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.seek(near(.zero)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekToTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(near(player.seekableTimeRange.start)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekToTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(near(player.seekableTimeRange.end)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSeekBeforeTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(near(CMTime(value: -10, timescale: 1))) { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(.zero))
                done()
            }
        }
    }

    func testSeekAfterTimeRangeEnd() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        waitUntil { done in
            player.seek(near(player.seekableTimeRange.end + CMTime(value: 10, timescale: 1))) { finished in
                expect(finished).to(beTrue())
                expect(player.time).to(equal(player.seekableTimeRange.end, by: beClose(within: 1)))
                done()
            }
        }
    }

    func testTimesDuringSeekBeforeTimeRangeStart() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.play()
        player.seek(near(CMTime(value: -10, timescale: 1)))
        expect(player.time).toAlways(beGreaterThanOrEqualTo(player.seekableTimeRange.start), until: .seconds(1))
    }

    func testOnDemandStartAtTime() {
        let configuration = PlayerItemConfiguration(position: at(.init(value: 10, timescale: 1)))
        let player = Player(item: .simple(url: Stream.onDemand.url, configuration: configuration))
        expect(player.time.seconds).toEventually(equal(10))
    }

    func testDvrStartAtTime() {
        let configuration = PlayerItemConfiguration(position: at(.init(value: 10, timescale: 1)))
        let player = Player(item: .simple(url: Stream.dvr.url, configuration: configuration))
        expect(player.time.seconds).toEventually(equal(10))
    }
}
