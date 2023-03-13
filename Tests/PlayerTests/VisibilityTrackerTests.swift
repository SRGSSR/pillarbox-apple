//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

@available(tvOS, unavailable)
final class VisibilityTrackerTests: TestCase {
    func testInitiallyVisible() {
        let visibilityTracker = VisibilityTracker()
        expect(visibilityTracker.isUserInterfaceHidden).to(beFalse())
    }

    func testInitiallyHidden() {
        let visibilityTracker = VisibilityTracker(isUserInterfaceHidden: true)
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    func testToggle() {
        let visibilityTracker = VisibilityTracker()
        visibilityTracker.toggle()
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    func testAutoHideWhilePlaying() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker.player = player
        expect(visibilityTracker.isUserInterfaceHidden).toEventually(beTrue(), timeout: .seconds(1))
    }

    func testNoAutoHideWhilePaused() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    func testNoAutoHideWithEmptyPlayer() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player()
        expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    func testNoAutoHideWithoutPlayer() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    func testReset() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker.player = player
        expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(400))
        visibilityTracker.reset()
        expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(400))
    }

    func testResetDoesNotShowControls() {
        let visibilityTracker = VisibilityTracker(isUserInterfaceHidden: true)
        visibilityTracker.reset()
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    func testAutoHideAfterUnhide() {
        let visibilityTracker = VisibilityTracker(delay: 0.5, isUserInterfaceHidden: true)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker.player = player
        visibilityTracker.toggle()
        expect(visibilityTracker.isUserInterfaceHidden).toEventually(beTrue(), timeout: .seconds(1))
    }

    func testInvalidDelay() {
        guard nimbleThrowAssertionsEnabled() else { return }
        expect(VisibilityTracker(delay: -5)).to(throwAssertion())
    }
}
