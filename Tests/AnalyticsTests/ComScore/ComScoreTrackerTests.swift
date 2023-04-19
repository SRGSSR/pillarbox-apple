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

final class ComScoreTrackerTests: ComScoreTestCase {
    func testInitiallyPlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.ns_st_po).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testInitiallyPaused() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expectNoEvents(during: .seconds(2)) {
            player.pause()
        }
    }

    func testPauseDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        player.play()
        expect(player.time.seconds).toEventually(beGreaterThan(1))

        expectAtLeastEvents(
            .pause { labels in
                expect(labels.ns_st_po).to(beCloseTo(1, within: 0.5))
            }
        ) {
            player.pause()
        }
    }

    func testPlaybackEnd() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play(),
            .end { labels in
                expect(labels.ns_st_po).to(beCloseTo(1, within: 0.1))
            }
        ) {
            player.play()
        }
    }

    func testDestroyPlayerDuringPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play(),
            .end { labels in
                expect(labels.ns_st_po).to(beCloseTo(5, within: 0.1))
            }
        ) {
            // Ensure the listener identifier can be associated with the end event.
            player?.play()
            // We have to wait at least 5 seconds due to comScore behavior.
            expect(player?.time.seconds).toEventually(beGreaterThan(5))
            player = nil
        }
    }

    func testSeekWhilePlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastEvents(
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

    func testSeekWhilePause() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expect(player.playbackState).toEventually(equal(.paused))

        expectNoEvents(during: .seconds(2)) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }

        expectAtLeastEvents(
            .play { labels in
                expect(labels.ns_st_po).to(beCloseTo(7, within: 0.5))
            }
        ) {
            player.play()
        }
    }

    func testFailure() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
            ]
        ))

        expectNoEvents(during: .seconds(3)) {
            player.play()
        }
    }

    func testOnDemandDvrProperties() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter()
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
            trackerAdapters: [
                ComScoreTracker.adapter()
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
            trackerAdapters: [
                ComScoreTracker.adapter()
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
            trackerAdapters: [
                ComScoreTracker.adapter()
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

    func testMetadata() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in
                    [
                        "meta_1": "custom-1",
                        "meta_2": "42"
                    ]
                }
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.metadata("meta_1")).to(equal("custom-1"))
                expect(labels.metadata("meta_2")).to(equal(42))
            }
        ) {
            player.play()
        }
    }
}
