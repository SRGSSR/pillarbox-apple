//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation

final class PlayerItemTrackerTests: TestCase {
    func testWithInitialItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            let player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                metadata: (),
                trackers: [
                    .init(trackerType: TrackerMock.self) { _ in
                        .init()
                    }
                ]
            ))
            player.play()
        }
    }

    func testWithoutInitialItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            let player = Player()
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                metadata: (),
                trackers: [
                    .init(trackerType: TrackerMock.self) { _ in
                        .init()
                    }
                ]
            ))
            player.play()
        }
    }

    func testWithFailedItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            let player = Player(item: .simple(
                url: Stream.unavailable.url,
                metadata: Void(),
                trackers: [
                    .init(trackerType: TrackerMock.self) { _ in
                        .init()
                    }
                ])
            )
            player.play()
        }
    }

    func testPlayerDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            _ = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                metadata: (),
                trackers: [
                    .init(trackerType: TrackerMock.self) { _ in
                        .init()
                    }
                ]
            ))
        }
    }

    func testPlayerItemDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: TrackerMock.state) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                metadata: (),
                trackers: [
                    .init(trackerType: TrackerMock.self) { _ in
                        .init()
                    }
                ]
            )
        }
    }
}
