//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class NowPlayingTests: XCTestCase {
    func testMergeBothNil() {
        expect(NowPlaying.Info.merge(nil, nil)).to(beNil())
    }

    func testMergeBothEmpty() {
        expect(NowPlaying.Info.merge([:], [:])).to(beNil())
    }

    func testMergeFirstNil() {
        let info = NowPlaying.Info.merge(nil, ["String": 1012])
        expect(info).to(equal(info, by: ~=))
    }

    func testMergeSecondNil() {
        let info = NowPlaying.Info.merge(["String": 1012], nil)
        expect(info).to(equal(info, by: ~=))
    }

    func testMergeBothNotNil() {
        let actual = NowPlaying.Info.merge(["S1": 1012], ["S2": 1337])
        let expected = [
            "S1": 1012,
            "S2": 1337
        ]
        expect(actual).to(equal(expected, by: ~=))
    }
}
