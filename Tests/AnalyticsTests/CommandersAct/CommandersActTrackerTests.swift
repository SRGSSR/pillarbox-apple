//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import Player
import XCTest

final class CommandersActTrackerTests: CommandersActTestCase {
    func testPlay() {
        let player = Player(item: .simple(
            url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing), timeout: .seconds(10))

        expectAtLeastEvents(
            [
                .pause()
            ]
        ) {
            player.pause()
        }

        expectAtLeastEvents(
            [
                .play()
            ]
        ) {
            player.play()
        }
    }
}
