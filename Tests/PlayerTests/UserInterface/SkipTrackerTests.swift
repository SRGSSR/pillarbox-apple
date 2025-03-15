//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

#if os(iOS)
final class SkipTrackerTests: TestCase {
    func testAlwaysIdleWithoutPlayer() {
        let skipTracker = SkipTracker()
        skipTracker.requestSkip(.forward)
        skipTracker.requestSkip(.forward)
        expect(skipTracker.state).to(equal(.idle))
    }

    func testTriggerWithIdenticalSkips() {
    }

    func testCannotTriggerWithMixedSkips() {
    }

    func testCannotTriggerAfterDelay() {
    }

    func testKeepEnableWithMixedSkips() {
    }

    func testResetAfterDelay() {
    }

    func testCount() {
    }

    func testInvalidCount() {
    }

    func testInvalidDelay() {
    }

    func testPlayerChangeResetsTracking() {
    }

    func testDeallocation() {
    }

    func testDeallocationWhilePlaying() {
    }
}
#endif
