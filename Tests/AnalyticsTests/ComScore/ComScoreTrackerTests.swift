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

// Testing comScore end events is a bit tricky:
//   1. Apparently comScore will never emit events if a play event is followed by an end event within ~5 seconds. For
//      this reason all tests checking end events must wait ~5 seconds after a play event.
//   2. End events are emitted automatically to close a session when the `SCORStreamingAnalytics` is destroyed. Since
//      we are not notifying the end event ourselves in such cases we cannot customize the end event labels directly.
//      Fortunately we can customize them indirectly, though, since the end event inherits labels from a former event.
//      Thus, to test end events resulting from tracker deallocation we need to have another event sent within the same
//      expectation first so that the end event is provided a listener identifier.
final class ComScoreTrackerTests: ComScoreTestCase {
    func testGlobals() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_mp).to(equal("Pillarbox"))
                expect(labels.ns_st_mv).to(equal(PackageInfo.version))
                expect(labels.cs_ucfr).to(beEmpty())
            }
        ) {
            player.play()
        }
    }

    func testInitiallyPlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_po).to(beCloseTo(0, within: 2))
            }
        ) {
            player.play()
        }
    }

    func testInitiallyPaused() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectNoHits(during: .seconds(2)) {
            player.pause()
        }
    }

    func testPauseDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        expect(player.time.seconds).toEventually(beGreaterThan(1))

        expectAtLeastHits(
            pause { labels in
                expect(labels.ns_st_po).to(beCloseTo(1, within: 0.5))
            }
        ) {
            player.pause()
        }
    }

    func testPlaybackEnd() {
        let player = Player(item: .simple(
            // See 1. at the top of this file.
            url: Stream.mediumOnDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectAtLeastHits(
            play(),
            end { labels in
                expect(labels.ns_st_po).to(beCloseTo(Stream.mediumOnDemand.duration.seconds, within: 0.5))
            }
        ) {
            player.play()
        }
    }

    func testDestroyPlayerDuringPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectAtLeastHits(
            play(),
            end { labels in
                expect(labels.ns_st_po).to(beCloseTo(5, within: 0.5))
            }
        ) {
            // See 2. at the top of this file.
            player?.play()
            // See 1. at the top of this file.
            expect(player?.time.seconds).toEventually(beGreaterThan(5))
            player = nil
        }
    }

    func testFailure() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectNoHits(during: .seconds(3)) {
            player.play()
        }
    }

    func testDisableTrackingDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        expectAtLeastHits(play(), end()) {
            // See 2. at the top of this file.
            player.play()
            // See 1. at the top of this file.
            expect(player.time.seconds).toEventually(beGreaterThan(5))
            player.isTrackingEnabled = false
        }
    }

    func testEnableTrackingDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))

        player.isTrackingEnabled = false

        expectNoHits(during: .seconds(2)) {
            player.play()
        }

        expectAtLeastHits(play()) {
            player.isTrackingEnabled = true
        }
    }

    func testInitialPlaybackRate() {
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
            player.setDesiredPlaybackSpeed(2)
            player.play()
        }
    }

    func testOnDemandStartAtGivenPosition() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ],
            configuration: .init(position: at(.init(value: 100, timescale: 1)))
        ))
        expectAtLeastHits(
            play { labels in
                expect(labels.ns_st_po).to(beCloseTo(100, within: 5))
            }
        ) {
            player.play()
        }
    }

    func testReplay() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                ComScoreTracker.adapter { _ in .test }
            ]
        ))
        var ns_st_id: String?
        expectAtLeastHits(
            play { labels in
                expect(labels["media_title"]).to(equal("name"))
                expect(labels.ns_st_id).notTo(beNil())
                ns_st_id = labels.ns_st_id
            },
            end()
        ) {
            player.play()
        }
        expectAtLeastHits(
            play { labels in
                expect(labels["media_title"]).to(equal("name"))
                expect(labels.ns_st_id).notTo(beNil())
                expect(labels.ns_st_id).notTo(equal(ns_st_id))
            }
        ) {
            player.replay()
        }
    }
}
