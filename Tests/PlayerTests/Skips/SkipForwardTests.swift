//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class SkipForwardTests: TestCase {
    private func isSeekingPublisher(for player: Player) -> AnyPublisher<Bool, Never> {
        player.propertiesPublisher
            .slice(at: \.isSeeking)
            .eraseToAnyPublisher()
    }

    func testSkipWhenEmpty() {
        let player = Player()
        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        waitUntil { done in
            player.skipForward { _ in
                expect(player.time()).to(equal(player.forwardSkipTime, by: beClose(within: player.chunkDuration.seconds)))
                done()
            }
        }
    }

    func testMultipleSkipsForOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beFalse())
            }

            player.skipForward { finished in
                expect(player.time()).to(equal(CMTimeMultiply(player.forwardSkipTime, multiplier: 2), by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipForDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time()
        waitUntil { done in
            player.skipForward { finished in
                expect(player.time()).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    func testSkipNearEndDoesNotSeekAnymore() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))
        let seekTo = Stream.onDemand.duration - CMTime(value: 1, timescale: 1)

        waitUntil { done in
            player.seek(at(seekTo)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        expectNothingPublishedNext(from: isSeekingPublisher(for: player), during: .seconds(2)) {
            player.skipForward()
        }
    }

    func testSkipNearEndCompletion() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))
        let seekTo = Stream.onDemand.duration - CMTime(value: 1, timescale: 1)

        waitUntil { done in
            player.seek(at(seekTo)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(seekTo, by: beClose(within: 0.5)))
                done()
            }
        }
    }
}
