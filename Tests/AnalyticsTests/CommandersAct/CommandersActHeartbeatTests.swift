//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Combine
import Nimble
@testable import PillarboxPlayer
import PillarboxStreams

final class CommandersActHeartbeatTests: CommandersActTestCase {
    private var cancellables = Set<AnyCancellable>()

    private static func player(from stream: PillarboxStreams.Stream, into cancellables: inout Set<AnyCancellable>) -> Player {
        let heartbeat = CommandersActHeartbeat(delay: 0.1, posInterval: 0.1, uptimeInterval: 0.2, queue: .main)
        let player = Player(item: .simple(url: stream.url))
        player.propertiesPublisher
            .sink { properties in
                heartbeat.update(with: .init(playerProperties: properties, time: .zero, date: nil, metrics: nil)) { properties in
                    ["media_volume": properties.isMuted ? "0" : "100"]
                }
            }
            .store(in: &cancellables)
        return player
    }

    override func tearDown() {
        super.tearDown()
        cancellables = []
    }

    func testNoHeartbeatInitially() {
        _ = Self.player(from: .onDemand, into: &cancellables)
        expectNoHits(during: .milliseconds(500))
    }

    func testOnDemandHeartbeatAfterPlay() {
        let player = Self.player(from: .onDemand, into: &cancellables)
        expectAtLeastHits(pos(), pos()) {
            player.play()
        }
    }

    func testLiveHeartbeatAfterPlay() {
        let player = Self.player(from: .live, into: &cancellables)
        expectAtLeastHits(pos(), uptime(), pos(), pos(), uptime()) {
            player.play()
        }
    }

    func testDvrHeartbeatAfterPlay() {
        let player = Self.player(from: .dvr, into: &cancellables)
        expectAtLeastHits(pos(), uptime(), pos(), pos(), uptime()) {
            player.play()
        }
    }

    func testNoHeartbeatAfterPause() {
        let player = Self.player(from: .onDemand, into: &cancellables)
        expectAtLeastHits(pos()) {
            player.play()
        }
        expectNoHits(during: .milliseconds(500)) {
            player.pause()
        }
    }

    func testHeartbeatPropertyUpdate() {
        let player = Self.player(from: .onDemand, into: &cancellables)
        expectAtLeastHits(
            pos { labels in
                expect(labels.media_volume).notTo(equal(0))
            }
        ) {
            player.play()
        }
        expectAtLeastHits(
            pos { labels in
                expect(labels.media_volume).to(equal(0))
            }
        ) {
            player.isMuted = true
        }
    }
}
