//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import Player
import Streams

private struct AssetMetadataMock: AssetMetadata {}

final class ComScoreTrackerRateTests: ComScoreTestCase {
    func testInitialRate() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
                expect(labels.ns_st_rt).to(equal(200))
            }
        ) {
            player.setDesiredPlaybackSpeed(2)
            player.play()
        }
    }

    func testWhenDifferentRateApplied() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            .playrt { labels in
                expect(labels.ns_st_rt).to(equal(200))
            }
        ) {
            player.setDesiredPlaybackSpeed(2)
        }
    }

    func testWhenSameRateApplied() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectNoHits(during: .seconds(2)) {
            player.setDesiredPlaybackSpeed(1)
        }
    }
}
