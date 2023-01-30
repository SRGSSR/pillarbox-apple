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
        expect(ItemState.failed(error: StructError())).to(equal(.failed(error: StructError())))
    }

    func testInequality() {
        expect(PlaybackState.idle).notTo(equal(.playing))
        expect(PlaybackState.failed(error: EnumError.error1)).notTo(equal(.failed(error: EnumError.error2)))
    }

    func testSimilarity() {
        expect(PlaybackState.idle).to(equal(.idle))
        expect(PlaybackState.playing).to(equal(.playing))
        expect(PlaybackState.paused).to(equal(.paused))
        expect(PlaybackState.ended).to(equal(.ended))
        expect(ItemState.failed(error: StructError())).to(equal(.failed(error: StructError())))
    }
}
