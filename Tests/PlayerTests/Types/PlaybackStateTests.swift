//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class PlaybackStateTests: TestCase {
    func testAllCases() {
        expect(PlaybackState(itemState: .unknown, rate: 0)).to(equal(.idle))
        expect(PlaybackState(itemState: .unknown, rate: 1)).to(equal(.idle))
        expect(PlaybackState(itemState: .readyToPlay, rate: 0)).to(equal(.paused))
        expect(PlaybackState(itemState: .readyToPlay, rate: 1)).to(equal(.playing))
        expect(PlaybackState(itemState: .ended, rate: 0)).to(equal(.ended))
        expect(PlaybackState(itemState: .ended, rate: 1)).to(equal(.ended))
    }
}
