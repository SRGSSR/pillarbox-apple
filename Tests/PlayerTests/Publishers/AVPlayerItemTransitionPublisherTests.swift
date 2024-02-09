//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxStreams

final class AVPlayerItemTransitionPublisherTests: TestCase {
    func testWhenEmpty() {
        let player = AVQueuePlayer()
        expectEqualPublished(
            values: [.advance(to: nil)],
            from: player.itemTransitionPublisher(),
            during: .milliseconds(100)
        )
    }

    func testDuringEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        expectEqualPublished(
            values: [.advance(to: item), .finish(with: item)],
            from: player.itemTransitionPublisher(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testBetweenPlayableItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            values: [.advance(to: item1), .advance(to: item2)],
            from: player.itemTransitionPublisher(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testFailingItemFollowedByPlayableItem() {
        let item1 = AVPlayerItem(url: Stream.unavailable.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            values: [.advance(to: item1), .stop(on: item1)],
            from: player.itemTransitionPublisher(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testFailingItemBetweenPlayableItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectEqualPublished(
            values: [.advance(to: item1), .stop(on: item2)],
            from: player.itemTransitionPublisher(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testReplaceCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.onDemand.url)
        let item2 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item1)
        expectEqualPublished(
            values: [.advance(to: item1), .advance(to: item2)],
            from: player.itemTransitionPublisher(),
            during: .milliseconds(100)
        ) {
            player.replaceCurrentItem(with: item2)
        }
    }

    func testRemoveCurrentItemFollowedByPlayableItem() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            values: [.advance(to: item1), .advance(to: item2)],
            from: player.itemTransitionPublisher(),
            during: .milliseconds(100)
        ) {
            player.remove(item1)
        }
    }

    func testRemoveAllItems() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        expectEqualPublished(
            values: [.advance(to: item), .finish(with: item)],
            from: player.itemTransitionPublisher(),
            during: .milliseconds(100)
        ) {
            player.removeAllItems()
        }
    }
}
