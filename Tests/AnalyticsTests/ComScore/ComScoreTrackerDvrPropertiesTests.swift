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

private struct AssetMetadataMock: AssetMetadata {}

final class ComScoreTrackerDvrPropertiesTests: ComScoreTestCase {
    func testOnDemand() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
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
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
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
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
                expect(labels.ns_st_ldo).to(equal(0))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            }
        ) {
            player.play()
        }
    }

    func testDvrAwayFromLiveEdge() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            .pause { labels in
                expect(labels.ns_st_ldo).to(equal(0))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            },
            .play { labels in
                expect(labels.ns_st_ldo).to(beCloseTo(4, within: 2))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            }
        ) {
            player.seek(at(player.time - CMTime(value: 4, timescale: 1)))
        }
    }
}
