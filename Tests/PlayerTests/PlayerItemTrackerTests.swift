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
                trackerAdapters: [
                    TrackerMock.adapter { _ in "" }
                ]
            ))
            player.play()
        }
    }

    func testWithFailedItem() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            let player = Player(item: .simple(
                url: Stream.unavailable.url,
                trackerAdapters: [
                    TrackerMock.adapter { _ in "" }
                ]
            ))
            player.play()
        }
    }

    func testPlayerDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: TrackerMock.state) {
            _ = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerMock.adapter { _ in "" }
                ]
            ))
        }
    }

    func testPlayerItemDeinit() {
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: TrackerMock.state) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerMock.adapter { _ in "" }
                ]
            )
        }
    }

    func testMetadata() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .update("metadata"), .disabled, .deinitialized], from: TrackerMock.state) {
            let player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    TrackerMock.adapter { _ in "metadata" }
                ]
            ))
            player.play()
        }
    }

    func testMetadataUpdate() {
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .update("title0"), .update("title1"), .disabled, .deinitialized], from: TrackerMock.state, timeout: .seconds(3)) {
            let player = Player(item: .metadataUpdate(delay: 1, trackerAdapters: [
                TrackerMock.adapter { $0.title ?? "" }
            ]))
            player.play()
        }
    }
}
