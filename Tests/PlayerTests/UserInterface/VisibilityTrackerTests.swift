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
final class VisibilityTrackerTests: TestCase {
    func testInitiallyVisible() {
        let visibilityTracker = VisibilityTracker()
        expect(visibilityTracker.isUserInterfaceHidden).to(beFalse())
    }

    func testInitiallyHidden() {
        let visibilityTracker = VisibilityTracker(isUserInterfaceHidden: true)
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    func testNoToggleWithoutPlayer() {
        let visibilityTracker = VisibilityTracker()
        visibilityTracker.toggle()
        expect(visibilityTracker.isUserInterfaceHidden).to(beFalse())
    }

    func testToggle() {
        let visibilityTracker = VisibilityTracker()
        visibilityTracker.player = Player()
        visibilityTracker.toggle()
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    func testInitiallyVisibleIfPaused() {
        let visibilityTracker = VisibilityTracker(delay: 0.5, isUserInterfaceHidden: true)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        expect(visibilityTracker.isUserInterfaceHidden).toEventually(beFalse())
    }

    func testVisibleWhenPaused() {
        let visibilityTracker = VisibilityTracker(delay: 0.5, isUserInterfaceHidden: true)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        visibilityTracker.player = player
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
        player.pause()
        expect(visibilityTracker.isUserInterfaceHidden).toEventually(beFalse())
    }

    func testNoAutoHideWhileIdle() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player()
        expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    func testAutoHideWhilePlaying() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker.player = player
        expect(visibilityTracker.isUserInterfaceHidden).toEventually(beTrue())
    }

    func testNoAutoHideWhilePaused() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    func testNoAutoHideWhileEnded() {
        let visibilityTracker = VisibilityTracker(delay: Stream.shortOnDemand.duration.seconds + 0.5)
        let player = Player(item: PlayerItem.simple(url: Stream.shortOnDemand.url))
        player.play()
        visibilityTracker.player = player
        expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    func testNoAutoHideWhileFailed() {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.unavailable.url))
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

    func testResetAutoHide() {
        let visibilityTracker = VisibilityTracker(delay: 0.3)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        visibilityTracker.player = player
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))
        expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(200))
        visibilityTracker.reset()
        expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(200))
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
        expect(visibilityTracker.isUserInterfaceHidden).toEventually(beTrue())
    }

    func testInvalidDelay() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(VisibilityTracker(delay: -5)).to(throwAssertion())
    }

    func testPlayerChangeDoesNotHideUserInterface() {
        let visibilityTracker = VisibilityTracker()
        visibilityTracker.player = Player()
        expect(visibilityTracker.isUserInterfaceHidden).to(beFalse())
    }

    func testPlayerChangeDoesNotShowUserInterface() {
        let visibilityTracker = VisibilityTracker(isUserInterfaceHidden: true)
        visibilityTracker.player = Player()
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    func testPlayerChangeResetsAutoHide() {
        let player1 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player1.play()
        expect(player1.playbackState).toEventually(equal(.playing))

        let player2 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player2.play()
        expect(player2.playbackState).toEventually(equal(.playing))

        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = player1
        expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(400))

        visibilityTracker.player = player2
        expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(400))
    }

    func testDeallocation() {
        var visibilityTracker: VisibilityTracker? = VisibilityTracker()
        weak var weakVisibilityTracker = visibilityTracker
        autoreleasepool {
            visibilityTracker = nil
        }
        expect(weakVisibilityTracker).to(beNil())
    }

    func testDeallocationWhilePlaying() {
        var visibilityTracker: VisibilityTracker? = VisibilityTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker?.player = player
        expect(player.playbackState).toEventually(equal(.playing))

        weak var weakVisibilityTracker = visibilityTracker
        autoreleasepool {
            visibilityTracker = nil
        }
        expect(weakVisibilityTracker).to(beNil())
    }
}
#endif
