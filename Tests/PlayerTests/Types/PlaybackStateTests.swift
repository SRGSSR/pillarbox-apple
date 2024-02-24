//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class PlaybackStateTests: TestCase {
    func testAllCases() {
        expect(PlaybackState(itemStatus: .unknown, rate: 0)).to(equal(.idle))
        expect(PlaybackState(itemStatus: .unknown, rate: 1)).to(equal(.idle))
        expect(PlaybackState(itemStatus: .readyToPlay, rate: 0)).to(equal(.paused))
        expect(PlaybackState(itemStatus: .readyToPlay, rate: 1)).to(equal(.playing))
        expect(PlaybackState(itemStatus: .ended, rate: 0)).to(equal(.ended))
        expect(PlaybackState(itemStatus: .ended, rate: 1)).to(equal(.ended))
    }
}
