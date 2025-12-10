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

    @MainActor
    func testInitiallyVisibleIfPaused() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5, isUserInterfaceHidden: true)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        await expect(visibilityTracker.isUserInterfaceHidden).toEventually(beFalse())
    }

    @MainActor
    func testVisibleWhenPaused() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5, isUserInterfaceHidden: true)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        visibilityTracker.player = player
        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
        player.pause()
        await expect(visibilityTracker.isUserInterfaceHidden).toEventually(beFalse())
    }

    @MainActor
    func testNoAutoHideWhileIdle() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player()
        await expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testAutoHideWhilePlaying() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker.player = player
        await expect(visibilityTracker.isUserInterfaceHidden).toEventually(beTrue())
    }

    @MainActor
    func testNoAutoHideWhilePaused() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        await expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testNoAutoHideWhileEnded() async {
        let visibilityTracker = VisibilityTracker(delay: Stream.shortOnDemand.duration.seconds + 0.5)
        let player = Player(item: PlayerItem.simple(url: Stream.shortOnDemand.url))
        player.play()
        visibilityTracker.player = player
        await expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testNoAutoHideWhileFailed() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player(item: PlayerItem.simple(url: Stream.unavailable.url))
        await expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testNoAutoHideWithEmptyPlayer() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = Player()
        await expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testNoAutoHideWithoutPlayer() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5)
        await expect(visibilityTracker.isUserInterfaceHidden).toNever(beTrue(), until: .seconds(1))
    }

    @MainActor
    func testResetAutoHide() async {
        let visibilityTracker = VisibilityTracker(delay: 0.3)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        visibilityTracker.player = player
        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))
        await expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(200))
        visibilityTracker.reset()
        await expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(200))
    }

    func testResetDoesNotShowControls() {
        let visibilityTracker = VisibilityTracker(isUserInterfaceHidden: true)
        visibilityTracker.reset()
        expect(visibilityTracker.isUserInterfaceHidden).to(beTrue())
    }

    @MainActor
    func testAutoHideAfterUnhide() async {
        let visibilityTracker = VisibilityTracker(delay: 0.5, isUserInterfaceHidden: true)
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker.player = player
        visibilityTracker.toggle()
        await expect(visibilityTracker.isUserInterfaceHidden).toEventually(beTrue())
    }

    func testInvalidDelay() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
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

    @MainActor
    func testPlayerChangeResetsAutoHide() async {
        let player1 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player1.play()
        await expect(player1.playbackState).toEventually(equal(.playing))

        let player2 = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player2.play()
        await expect(player2.playbackState).toEventually(equal(.playing))

        let visibilityTracker = VisibilityTracker(delay: 0.5)
        visibilityTracker.player = player1
        await expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(400))

        visibilityTracker.player = player2
        await expect(visibilityTracker.isUserInterfaceHidden).toAlways(beFalse(), until: .milliseconds(400))
    }

    func testDeallocation() {
        var visibilityTracker: VisibilityTracker? = VisibilityTracker()
        weak var weakVisibilityTracker = visibilityTracker
        autoreleasepool {
            visibilityTracker = nil
        }
        expect(weakVisibilityTracker).to(beNil())
    }

    @MainActor
    func testDeallocationWhilePlaying() async {
        var visibilityTracker: VisibilityTracker? = VisibilityTracker()
        let player = Player(item: PlayerItem.simple(url: Stream.onDemand.url))
        player.play()
        visibilityTracker?.player = player
        await expect(player.playbackState).toEventually(equal(.playing))

        weak var weakVisibilityTracker = visibilityTracker
        autoreleasepool {
            visibilityTracker = nil
        }
        expect(weakVisibilityTracker).to(beNil())
    }
}
#endif
