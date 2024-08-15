//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

import Nimble
import PillarboxCircumspect
import PillarboxPlayer
import PillarboxStreams
import XCTest

final class MetricsTrackerTests: MonitoringTestCase {
    func testEntirePlayback() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        expectAtLeastHits(
            start(),
            heartbeat(),
            stop { payload in
                expect(payload.data.position).to(beCloseTo(1000, within: 100))
            }
        ) {
            player.play()
        }
    }

    func testError() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        expectAtLeastHits(
            start(),
            error { payload in
                let data = payload.data
                expect(data.severity).to(equal(.fatal))
                expect(data.name).to(equal("NSURLErrorDomain(-1100)"))
                expect(data.message).to(equal("The requested URL was not found on this server."))
                expect(data.position).to(beNil())
            }
        ) {
            player.play()
        }
    }

    func testNoStopWithoutStart() {
        var player: Player? = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        _ = player
        expectNoHits(during: .milliseconds(500)) {
            player = nil
        }
    }

    func testHeartbeats() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .heartbeatTest) { _ in .test }
            ]
        ))
        expectAtLeastHits(start(), heartbeat(), heartbeat()) {
            player.play()
        }
    }

    func testSessionIdentifierRenewedWhenReplayingAfterEnd() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        var sessionId: String?
        expectAtLeastHits(
            start { payload in
                sessionId = payload.sessionId
            },
            heartbeat { payload in
                expect(payload.sessionId).to(equal(sessionId))
            },
            stop { payload in
                expect(payload.sessionId).to(equal(sessionId))
            }
        ) {
            player.play()
        }
        expectAtLeastHits(
            start { payload in
                expect(payload.sessionId).notTo(equal(sessionId))
            }
        ) {
            player.replay()
        }
    }

    func testSessionIdentifierRenewedWhenReplayingAfterFatalError() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        var sessionId: String?
        expectAtLeastHits(
            start { payload in
                sessionId = payload.sessionId
            },
            error { payload in
                expect(payload.sessionId).to(equal(sessionId))
            }
        )
        expectAtLeastHits(
            start { payload in
                expect(payload.sessionId).notTo(equal(sessionId))
            }
        ) {
            player.replay()
        }
    }

    func testSessionIdentifierClearedAfterPlaybackEnd() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        expectAtLeastHits(
            start(),
            heartbeat(),
            stop()
        ) {
            player.play()
        }
        expect(player.currentSessionIdentifiers(trackedBy: MetricsTracker.self)).to(beEmpty())
    }

    func testSessionIdentifierPersistenceAfterFatalError() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { _ in .test }
            ]
        ))
        var sessionId: String?
        expectAtLeastHits(
            start { payload in
                sessionId = payload.sessionId
            },
            error()
        )
        expect(player.currentSessionIdentifiers(trackedBy: MetricsTracker.self)).to(equalDiff([sessionId!]))
    }

    func testPayloads() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) { .test }
            ]
        ))
        expectAtLeastHits(
            start { payload in
                expect(payload.version).to(equal(1))

                let data = payload.data

                let device = data.device
                expect(device.id).notTo(beNil())
                expect(device.model).notTo(beNil())
                expect(device.type).notTo(beNil())

                let media = data.media
                expect(media.assetUrl).to(equal(URL(string: "https://localhost/asset.m3u8")))
                expect(media.id).to(equal("identifier"))
                expect(media.metadataUrl).to(equal(URL(string: "https://localhost/metadata.json")))
                expect(media.origin).notTo(beNil())

                let os = data.os
                expect(os.name).notTo(beNil())
                expect(os.version).notTo(beNil())

                let player = data.player
                expect(player.name).to(equal("Pillarbox"))
                expect(player.version).to(equal(Player.version))
            },
            heartbeat { payload in
                expect(payload.version).to(equal(1))

                let data = payload.data
                expect(data.airplay).to(beFalse())
                expect(data.streamType).to(equal("On-demand"))
                expect(data.vpn).to(beFalse())
            }
        ) {
            player.play()
        }
    }
}
