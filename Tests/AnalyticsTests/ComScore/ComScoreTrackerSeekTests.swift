//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Nimble
import Player
import Streams

private struct AssetMetadataMock: AssetMetadata {}

final class ComScoreTrackerSeekTests: ComScoreTestCase {
    func testSeekWhilePlaying() {
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
            .pause { labels in
                expect(labels.ns_st_po).to(beCloseTo(0, within: 0.5))
            },
            .play { labels in
                expect(labels.ns_st_po).to(beCloseTo(7, within: 0.5))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    func testSeekWhilePaused() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        expect(player.playbackState).toEventually(equal(.paused))

        expectNoHits(during: .seconds(2)) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }

        expectAtLeastHits(
            .play { labels in
                expect(labels.ns_st_po).to(beCloseTo(7, within: 0.5))
            }
        ) {
            player.play()
        }
    }
}
