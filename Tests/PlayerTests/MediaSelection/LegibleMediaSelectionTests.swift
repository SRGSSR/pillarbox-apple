//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import Streams
import XCTest

final class LegibleMediaSelectionTests: TestCase {
    func testEmpty() {
        let player = Player()
        expect(player.legibleMediaSelectionOptions).toAlways(beEmpty(), until: .seconds(2))
    }

    func testPlayback() {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.legibleMediaSelectionOptions).toEventuallyNot(beEmpty())
    }

    func testFailure() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.legibleMediaSelectionOptions).toAlways(beEmpty(), until: .seconds(2))
    }
}
