//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import ObjectiveC
import PillarboxCircumspect
import PillarboxStreams

#if os(iOS)
final class SkipTrackerTests: TestCase {
    func testRequestsWithEmptyPlayer() {
        let skipTracker = SkipTracker()
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.activeState).to(beNil())
    }

    func testFulfilledRequest() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
    }

    func testUnfulfilledRequest() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.live.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
    }

    func testIdenticalRequests() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.activeState).to(beNil())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .backward, count: 1)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .backward, count: 2)))
    }

    func testMixedRequests() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.activeState).to(beNil())
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.activeState).to(beNil())
        expect(skipTracker.requestSkip(.forward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .forward, count: 1)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .backward, count: 1)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .backward, count: 2)))
    }

    func testSpacedRequests() {
        let skipTracker = SkipTracker(delay: 0.1)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        wait(for: .milliseconds(200))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.activeState).to(beNil())
    }

    func testResetAfterDelay() {
        let skipTracker = SkipTracker(delay: 0.1)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .backward, count: 1)))
        wait(for: .milliseconds(200))
        expect(skipTracker.activeState).to(beNil())
    }

    func testPlayerPosition() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.requestSkip(.forward)).to(beTrue())
        expect(player.time().seconds).toEventually(beGreaterThan(5))
    }

    func testInvalidCount() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(SkipTracker(delay: 0)).to(throwAssertion())
    }

    func testInvalidDelay() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(SkipTracker(count: 0)).to(throwAssertion())
    }

    func testPlayerChangeResetsTracking() {
        let player1 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        expect(player1.playbackState).toEventually(equal(.paused))

        let player2 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        expect(player2.playbackState).toEventually(equal(.paused))

        let skipTracker = SkipTracker()
        skipTracker.player = player1
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.activeState).to(equal(.init(skip: .backward, count: 1)))

        skipTracker.player = player2
        expect(skipTracker.activeState).to(beNil())
    }
}
#endif
