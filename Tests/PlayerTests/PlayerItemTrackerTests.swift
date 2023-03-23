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
                metadata: EmptyAssetMetadata(),
                trackerAdapters: [
                    TrackerMock.adapter { _ in
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
                metadata: EmptyAssetMetadata(),
                trackerAdapters: [
                    TrackerMock.adapter { _ in
                        TrackerMock.Metadata()
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
                metadata: EmptyAssetMetadata(),
                trackerAdapters: [
                    TrackerMock.adapter { _ in
                        TrackerMock.Metadata()
                    }
                ]
            ))
            player.play()
        }
    }

    func testPlayerDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            _ = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                metadata: EmptyAssetMetadata(),
                trackerAdapters: [
                    TrackerMock.adapter { _ in
                        TrackerMock.Metadata()
                    }
                ]
            ))
        }
    }

    func testPlayerItemDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: TrackerMock.state) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                metadata: EmptyAssetMetadata(),
                trackerAdapters: [
                    TrackerMock.adapter { _ in
                        TrackerMock.Metadata()
                    }
                ]
            )
        }
    }
}
