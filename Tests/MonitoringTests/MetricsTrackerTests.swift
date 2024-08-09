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
            stop { payload in
                expect(payload.data.playerPosition).to(beCloseTo(1000, within: 100))
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
                expect(data.playerPosition).to(beNil())
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
                MetricsTracker.adapter(
                    configuration: .init(
                        serviceUrl: URL(string: "https://localhost")!,
                        heartbeatInterval: 1
                    )
                ) { _ in .test }
            ]
        ))
        expectAtLeastHits(
            start(),
            heartbeat { payload in
                expect(payload.data.playerPosition).to(beCloseTo(1000, within: 100))
            },
            heartbeat { payload in
                expect(payload.data.playerPosition).to(beCloseTo(2000, within: 100))
            }
        ) {
            player.play()
        }
    }

    func testStartPayload() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                MetricsTracker.adapter(configuration: .test) {
                    .init(
                        identifier: "identifier",
                        metadataUrl: URL(string: "https://localhost/metadata.json"),
                        assetUrl: URL(string: "https://localhost/asset.m3u8")
                    )
                }
            ]
        ))
        expectAtLeastHits(
            start { payload in
                expect(payload.version).to(equal("1.0.0"))

                let data = payload.data

                let device = data.device
                expect(device.id).notTo(beNil())
                expect(device.model).notTo(beNil())
                expect(device.type).notTo(beNil())

                let media = data.media
                expect(media.id).to(equal("identifier"))
                expect(media.metadataUrl).to(equal(URL(string: "https://localhost/metadata.json")))
                expect(media.assetUrl).to(equal(URL(string: "https://localhost/asset.m3u8")))
                expect(media.origin).notTo(beNil())

                let os = data.os
                expect(os.name).notTo(beNil())
                expect(os.version).notTo(beNil())

                let player = data.player
                expect(player.name).to(equal("Pillarbox"))
                expect(player.version).to(equal(Player.version))
            }
        ) {
            player.play()
        }
    }
}
