//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import CoreMedia
import Nimble
import Player
import Streams
import XCTest

private struct AssetMetadataMock: AssetMetadata {}

final class CommandersActTrackerDvrPropertiesTests: CommandersActTestCase {
    func testOnDemand() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
                expect(labels.media_timeshift).to(beNil())
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
                CommandersActTracker.adapter { _ in
                    .test(streamType: .live)
                }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
                expect(labels.media_timeshift).to(equal(0))
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
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
                expect(labels.media_timeshift).to(equal(0))
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
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            .seek { labels in
                expect(labels.media_timeshift).to(equal(0))
            },
            .play { labels in
                expect(labels.media_timeshift).to(equal(4))
            }
        ) {
            player.seek(at(player.timeRange.end - CMTime(value: 4, timescale: 1)))
        }
    }

    func testDestroyPlayerDuringPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        player?.pause()
        wait(for: .seconds(2))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            player = nil
        }
    }

    func testDestroyPlayerWhileInitiallyPaused() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))
        expect(player?.playbackState).toEventually(equal(.paused))

        expectNoHits(during: .seconds(5)) {
            player = nil
        }
    }
}
