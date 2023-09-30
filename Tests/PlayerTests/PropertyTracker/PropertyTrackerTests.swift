//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Combine
import Nimble
import Streams

final class PropertyTrackerTests: TestCase {
    func testUnbound() {
        let propertyTracker = PropertyTracker(keyPath: \.buffer)
        expectAtLeastEqualPublished(
            values: [0],
            from: propertyTracker.$value
        )
    }

    func testEmptyPlayer() {
        let propertyTracker = PropertyTracker(keyPath: \.buffer)
        expectAtLeastEqualPublished(
            values: [0],
            from: propertyTracker.$value
        ) {
            propertyTracker.player = Player()
        }
    }

    func testPlayerChange() {
        let propertyTracker = PropertyTracker(keyPath: \.buffer)
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        propertyTracker.player = player
        player.play()
        expect(propertyTracker.value).toEventuallyNot(equal(0))

        let buffer = propertyTracker.value
        expectAtLeastEqualPublished(
            values: [buffer, 0],
            from: propertyTracker.$value
        ) {
            propertyTracker.player = Player()
        }
    }

    func testPlayerSetToNil() {
        let propertyTracker = PropertyTracker(keyPath: \.buffer)
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        propertyTracker.player = player
        player.play()
        expect(propertyTracker.value).toEventuallyNot(equal(0))

        let buffer = propertyTracker.value
        expectAtLeastEqualPublished(
            values: [buffer, 0],
            from: propertyTracker.$value
        ) {
            propertyTracker.player = nil
        }
    }
}
