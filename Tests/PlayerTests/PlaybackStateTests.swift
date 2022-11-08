//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class PlaybackStateTests: XCTestCase {
    func testEquality() {
        expect(PlaybackState.idle).to(equal(.idle))
        expect(PlaybackState.playing).to(equal(.playing))
        expect(PlaybackState.paused).to(equal(.paused))
        expect(PlaybackState.ended).to(equal(.ended))
        expect(ItemState.failed(error: EnumError.any)).to(equal(.failed(error: EnumError.any)))
    }

    func testInequality() {
        expect(PlaybackState.idle).notTo(equal(.playing))
        expect(PlaybackState.failed(error: EnumError.error1)).notTo(equal(.failed(error: EnumError.error2)))
    }

    func testSimilarity() {
        expect(PlaybackState.idle).to(equal(.idle, by: ~=))
        expect(PlaybackState.playing).to(equal(.playing, by: ~=))
        expect(PlaybackState.paused).to(equal(.paused, by: ~=))
        expect(PlaybackState.ended).to(equal(.ended, by: ~=))
        expect(ItemState.failed(error: EnumError.any)).to(equal(.failed(error: EnumError.any), by: ~=))
    }
}
