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
        let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackers: [tracker]))
        expectAtLeastEqualPublished(values: [.enabled, .disabled], from: tracker.$state) {
            player.play()
        }
    }

    func testWithoutInitialItem() {
        let tracker = TrackerMock()
        let player = Player()

        expectAtLeastEqualPublished(values: [.unknown, .enabled, .disabled], from: tracker.$state) {
            player.append(.simple(url: Stream.shortOnDemand.url, trackers: [tracker]))
            player.play()
        }
    }
}
