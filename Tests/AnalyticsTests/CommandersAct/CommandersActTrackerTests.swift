//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import Player
import Streams
import XCTest

final class CommandersActTrackerTests: CommandersActTestCase {
    func testInitiallyPlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(.play()) {
            player.play()
        }
    }

    func testPauseDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing), timeout: .seconds(10))

        expectAtLeastEvents(.pause()) {
            player.pause()
        }

        expectAtLeastEvents(.play()) {
            player.play()
        }
    }
}
