//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Foundation

final class PlayerItemTrackerTests: TestCase {
    func testWithInitialItem() {
        let tracker = TrackerMock()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: tracker.$state) {
            let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackers: [tracker]))
            player.play()
        }
    }

    func testWithoutInitialItem() {
        let tracker = TrackerMock()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: tracker.$state) {
            let player = Player()
            player.append(.simple(url: Stream.shortOnDemand.url, trackers: [tracker]))
            player.play()
        }
    }

    func testWithFailedItem() {
        let tracker = TrackerMock()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: tracker.$state) {
            let player = Player(item: .simple(url: Stream.unavailable.url, trackers: [tracker]))
            player.play()
        }
    }

    func testPlayerDeinit() {
        var tracker: TrackerMock? = TrackerMock()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled, .deinitialized], from: tracker!.$state) {
            _ = Player(item: .simple(url: Stream.shortOnDemand.url, trackers: [tracker!]))
            tracker = nil
        }
    }

    func testPlayerItemDeinit() {
        var tracker: TrackerMock? = TrackerMock()
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: tracker!.$state) {
            _ = PlayerItem.simple(url: Stream.shortOnDemand.url, trackers: [tracker!])
            tracker = nil
        }
    }
}
