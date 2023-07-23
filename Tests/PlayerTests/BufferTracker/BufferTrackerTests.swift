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
import XCTest

final class BufferTrackerTests: TestCase {
    func testUnbound() {
        let bufferTracker = BufferTracker()
        expectAtLeastEqualPublished(
            values: [0],
            from: bufferTracker.changePublisher(at: \.buffer)
                .removeDuplicates()
        )
    }

    func testEmptyPlayer() {
        let bufferTracker = BufferTracker()
        expectAtLeastEqualPublished(
            values: [0],
            from: bufferTracker.changePublisher(at: \.buffer)
                .removeDuplicates()
        ) {
            bufferTracker.player = Player()
        }
    }

    func testPlayerChange() {
        let bufferTracker = BufferTracker()
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        bufferTracker.player = player
        player.play()
        expect(bufferTracker.buffer).toEventuallyNot(equal(0))

        let buffer = bufferTracker.buffer
        expectAtLeastEqualPublished(
            values: [buffer, 0],
            from: bufferTracker.changePublisher(at: \.buffer)
                .removeDuplicates()
        ) {
            bufferTracker.player = Player()
        }
    }

    func testPlayerSetToNil() {
        let bufferTracker = BufferTracker()
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        bufferTracker.player = player
        player.play()
        expect(bufferTracker.buffer).toEventuallyNot(equal(0))

        let buffer = bufferTracker.buffer
        expectAtLeastEqualPublished(
            values: [buffer, 0],
            from: bufferTracker.changePublisher(at: \.buffer)
                .removeDuplicates()
        ) {
            bufferTracker.player = nil
        }
    }
}
