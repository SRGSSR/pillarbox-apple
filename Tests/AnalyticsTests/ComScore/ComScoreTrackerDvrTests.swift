//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import ComScore
import CoreMedia
import Nimble
import Player
import Streams
import XCTest

private struct AssetMetadataMock: AssetMetadata {}

final class ComScoreTrackerDvrTests: ComScoreTestCase {
    func testOnDemandDvrProperties() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.ns_st_ldw).to(equal(0))
                expect(labels.ns_st_ldo).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testLiveDvrProperties() {
        let player = Player(item: .simple(
            url: Stream.live.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.ns_st_ldw).to(equal(0))
                expect(labels.ns_st_ldo).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testDvrPropertiesAtLiveEdge() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.ns_st_ldo).to(equal(0))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            }
        ) {
            player.play()
        }
    }

    func testDvrPropertiesAwayFromLiveEdge() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastEvents(
            .pause { labels in
                expect(labels.ns_st_ldo).to(equal(0))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            },
            .play { labels in
                expect(labels.ns_st_ldo).to(equal(4))
                expect(labels.ns_st_ldw).to(equal(Stream.dvr.duration.seconds))
            }
        ) {
            player.seek(at(player.timeRange.end - CMTime(value: 4, timescale: 1)))
        }
    }
}
