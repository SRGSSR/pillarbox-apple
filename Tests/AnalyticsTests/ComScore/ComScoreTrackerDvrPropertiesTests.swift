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

final class ComScoreTrackerDvrPropertiesTests: ComScoreTestCase {
    func testOnDemand() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_ldw).to(equal(0))
                expect(labels.ns_st_ldo).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testLive() {
        let player = Player(item: .simple(
            url: Stream.live.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_ldw).to(equal(0))
                expect(labels.ns_st_ldo).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testDvrAtLiveEdge() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_ldo).to(equal(0))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            }
        ) {
            player.play()
        }
    }

    @MainActor
    func testDvrAwayFromLiveEdge() async {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            pause { labels in
                expect(labels.ns_st_ldo).to(equal(0))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            },
            play { labels in
                expect(labels.ns_st_ldo).to(beCloseTo(10, within: 3))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            }
        ) {
            player.seek(at(player.time() - CMTime(value: 10, timescale: 1)))
        }
    }
}
