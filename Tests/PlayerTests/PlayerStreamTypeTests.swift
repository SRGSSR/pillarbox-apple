//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

@MainActor
final class PlayerStreamTypeTests: XCTestCase {
    func testEmpty() {
        let player = Player()
        expect(player.streamType).toAlways(equal(.unknown))
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
    }

    func testLive() {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
    }
}
