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
    func testEmptyPlayer() {
        let skipTracker = SkipTracker()
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.state).to(equal(.idle))
    }

    func testRequestSucceedsWhenSeekPossible() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.dvr.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
    }

    func testIdenticalSkips() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.idle))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(20)))
    }

    func testMixedSkips() {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.idle))
        expect(skipTracker.requestSkip(.forward)).to(beTrue())
        expect(skipTracker.state).to(equal(.idle))
        expect(skipTracker.requestSkip(.forward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingForward(10)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(20)))
    }

    func testCannotTriggerAfterDelay() {
        let skipTracker = SkipTracker(delay: 0.1)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        wait(for: .milliseconds(200))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.idle))
    }

    func testResetAfterDelay() {
        let skipTracker = SkipTracker(delay: 0.1)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))
        wait(for: .milliseconds(200))
        expect(skipTracker.state).to(equal(.idle))
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
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))

        skipTracker.player = player2
        expect(skipTracker.state).to(equal(.idle))
    }
}
#endif
