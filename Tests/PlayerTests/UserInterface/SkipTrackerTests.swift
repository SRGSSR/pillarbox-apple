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
import XCTest

#if os(iOS)
final class SkipTrackerTests: TestCase {
    func testRequestsWithEmptyPlayer() {
        let skipTracker = SkipTracker()
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.state).to(equal(.inactive))
    }

    @MainActor
    func testFulfilledRequest() async {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
    }

    @MainActor
    func testUnfulfilledRequest() async {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.live.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
    }

    @MainActor
    func testIdenticalRequests() async {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.state).to(equal(.inactive))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(20)))
    }

    @MainActor
    func testMixedRequests() async {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.state).to(equal(.inactive))
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.state).to(equal(.inactive))
        expect(skipTracker.requestSkip(.forward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingForward(10)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(20)))
    }

    @MainActor
    func testSpacedRequests() async {
        let skipTracker = SkipTracker(delay: 0.1)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        wait(for: .milliseconds(200))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.state).to(equal(.inactive))
    }

    @MainActor
    func testResetAfterDelay() async {
        let skipTracker = SkipTracker(delay: 0.1)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))
        wait(for: .milliseconds(200))
        expect(skipTracker.state).to(equal(.inactive))
    }

    @MainActor
    func testPlayerPosition() async {
        let skipTracker = SkipTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        skipTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))
        expect(skipTracker.requestSkip(.forward)).to(beFalse())
        expect(skipTracker.requestSkip(.forward)).to(beTrue())
        await expect(player.time().seconds).toEventually(beGreaterThan(5))
    }

    func testInvalidCount() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
        expect(SkipTracker(delay: 0)).to(throwAssertion())
    }

    func testInvalidDelay() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
        expect(SkipTracker(count: 0)).to(throwAssertion())
    }

    @MainActor
    func testPlayerChangeResetsTracking() async {
        let player1 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        await expect(player1.playbackState).toEventually(equal(.paused))

        let player2 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        await expect(player2.playbackState).toEventually(equal(.paused))

        let skipTracker = SkipTracker()
        skipTracker.player = player1
        expect(skipTracker.requestSkip(.backward)).to(beFalse())
        expect(skipTracker.requestSkip(.backward)).to(beTrue())
        expect(skipTracker.state).to(equal(.skippingBackward(10)))

        skipTracker.player = player2
        expect(skipTracker.state).to(equal(.inactive))
    }
}
#endif
