//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import CoreMedia
import Nimble
import PillarboxPlayer
import PillarboxStreams

final class ComScoreTrackerSeekTests: ComScoreTestCase {
    @MainActor
    func testSeekWhilePlaying() async {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            pause { labels in
                expect(labels.ns_st_po).to(beCloseTo(0, within: 0.5))
            },
            play { labels in
                expect(labels.ns_st_po).to(beCloseTo(7, within: 0.5))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    @MainActor
    func testSeekWhilePaused() async {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        await expect(player.playbackState).toEventually(equal(.paused))

        expectNoHits(during: .milliseconds(500)) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }

        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_po).to(beCloseTo(7, within: 0.5))
            }
        ) {
            player.play()
        }
    }
}
