//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import Streams
import XCTest

final class AudibleMediaSelectionTests: TestCase {
    func testEmpty() {
        let player = Player()
        expect(player.audibleMediaSelectionOptions).toAlways(beEmpty(), until: .seconds(2))
    }

    func testPlayback() {
        let player = Player(item: .simple(url: Stream.onDemandWithTracks.url))
        expect(player.audibleMediaSelectionOptions).toEventuallyNot(beEmpty())
    }

    func testFailure() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expect(player.audibleMediaSelectionOptions).toAlways(beEmpty(), until: .seconds(2))
    }
}
