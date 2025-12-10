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

    @MainActor
    func testSkipWhenEmpty() async {
        let player = Player()
        await waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        await waitUntil { done in
            player.skipForward { _ in
                expect(player.time()).to(equal(player.forwardSkipTime, by: beClose(within: player.chunkDuration.seconds)))
                done()
            }
        }
    }

    @MainActor
    func testMultipleSkipsForOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))

        await waitUntil { done in
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

    @MainActor
    func testSkipForLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        await expect(player.streamType).toEventually(equal(.live))
        await waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipForDvr() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.streamType).toEventually(equal(.dvr))
        let headTime = player.time()
        await waitUntil { done in
            player.skipForward { finished in
                expect(player.time()).to(equal(headTime, by: beClose(within: player.chunkDuration.seconds)))
                expect(finished).to(beTrue())
                done()
            }
        }
    }

    @MainActor
    func testSkipNearEndDoesNotSeekAnymore() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))
        let seekTo = Stream.onDemand.duration - CMTime(value: 1, timescale: 1)

        await waitUntil { done in
            player.seek(at(seekTo)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        expectNothingPublishedNext(from: isSeekingPublisher(for: player), during: .seconds(2)) {
            player.skipForward()
        }
    }

    @MainActor
    func testSkipNearEndCompletion() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        expect(player.time()).to(equal(.zero))
        let seekTo = Stream.onDemand.duration - CMTime(value: 1, timescale: 1)

        await waitUntil { done in
            player.seek(at(seekTo)) { finished in
                expect(finished).to(beTrue())
                done()
            }
        }

        await waitUntil { done in
            player.skipForward { finished in
                expect(finished).to(beTrue())
                expect(player.time()).to(equal(seekTo, by: beClose(within: 0.5)))
                done()
            }
        }
    }
}
