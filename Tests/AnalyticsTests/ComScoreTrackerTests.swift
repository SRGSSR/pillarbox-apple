//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import Player
import XCTest

final class ComScoreTrackerTests: XCTestCase {
    func testPlay() {
        let player = Player(item: .simple(
            url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        // no id

        player.play()
        expect(player.playbackState).toEventually(equal(.playing), timeout: .seconds(10))

        // id 1
        expectAtLeastComScoreEvents(
            [
                .pause()
            ]
        ) {
            player.pause()
        }

        // id 2
        expectAtLeastComScoreEvents(
            [
                .play()
            ]
        ) {
            player.play()
        }
    }
}
