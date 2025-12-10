//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble
import PillarboxPlayer
import PillarboxStreams

final class ComScoreTrackerRateTests: ComScoreTestCase {
    func testInitialRate() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_rt).to(equal(200))
            }
        ) {
            player.playbackSpeed = 2
            player.play()
        }
    }

    @MainActor
    func testWhenDifferentRateApplied() async {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            playrt { labels in
                expect(labels.ns_st_rt).to(equal(200))
            }
        ) {
            player.playbackSpeed = 2
        }
    }

    @MainActor
    func testWhenSameRateApplied() async {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        expectNoHits(during: .seconds(1)) {
            player.playbackSpeed = 1
        }
    }
}
