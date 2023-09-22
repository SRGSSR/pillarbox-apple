//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class PlaybackStateTests: TestCase {
    func testEquality() {
        expect(PlaybackState.idle).to(equal(.idle))
        expect(PlaybackState.playing).to(equal(.playing))
        expect(PlaybackState.paused).to(equal(.paused))
        expect(PlaybackState.ended).to(equal(.ended))
    }

    func testInequality() {
        expect(PlaybackState.idle).notTo(equal(.playing))
    }

    func testSimilarity() {
        expect(PlaybackState.idle).to(equal(.idle))
        expect(PlaybackState.playing).to(equal(.playing))
        expect(PlaybackState.paused).to(equal(.paused))
        expect(PlaybackState.ended).to(equal(.ended))
    }
}
