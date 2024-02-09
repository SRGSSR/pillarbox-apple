//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import PillarboxStreams

final class AVPlayerPublisherTests: TestCase {
    private static func errorPublisher(for player: AVPlayer) -> AnyPublisher<Error?, Never> {
        player.errorPublisher()
            .removeDuplicates { $0 as? NSError == $1 as? NSError }
            .eraseToAnyPublisher()
    }

    func testErrorEmpty() {
        let player = AVQueuePlayer()
        expectNothingPublished(from: Self.errorPublisher(for: player), during: .milliseconds(100))
    }

    func testError() {
        let player = AVQueuePlayer(
            playerItem: .init(url: Stream.unavailable.url)
        )
        expectAtLeastPublished(
            values: [nil, PlayerError.resourceNotFound],
            from: Self.errorPublisher(for: player),
            to: beEqual
        )
    }

    func testSmoothCurrentItemWhenEmpty() {
        let player = AVQueuePlayer()
        expectEqualPublished(
            values: [nil],
            from: player.smoothCurrentItemPublisher(),
            during: .milliseconds(100)
        )
    }

    func testSmoothCurrentItemEntirePlayback() {
        let player = AVQueuePlayer(
            playerItem: .init(url: Stream.shortOnDemand.url)
        )
        expectEqualPublished(
            values: [Stream.shortOnDemand.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testSmoothCurrentItemTransition() {
        let player = AVQueuePlayer(
            items: [
                .init(url: Stream.shortOnDemand.url),
                .init(url: Stream.onDemand.url)
            ]
        )
        expectEqualPublished(
            values: [Stream.shortOnDemand.url, Stream.onDemand.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testSmoothCurrentItemWithFailure() {
        let player = AVQueuePlayer(
            playerItem: .init(url: Stream.unavailable.url)
        )
        expectEqualPublished(
            values: [Stream.unavailable.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testSmoothCurrentItemTransitionToFailure() {
        let player = AVQueuePlayer(
            items: [
                .init(url: Stream.shortOnDemand.url),
                .init(url: Stream.unavailable.url)
            ]
        )
        expectEqualPublished(
            values: [Stream.shortOnDemand.url, Stream.unavailable.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testSmoothCurrentItemWithFailingMiddleItem() {
        let player = AVQueuePlayer(
            items: [
                .init(url: Stream.shortOnDemand.url),
                .init(url: Stream.unavailable.url),
                .init(url: Stream.onDemand.url),
            ]
        )
        expectEqualPublished(
            values: [Stream.shortOnDemand.url, Stream.unavailable.url, Stream.onDemand.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testSmoothCurrentItemWhenReplacingCurrentItem() {
        let player = AVQueuePlayer(
            playerItem: .init(url: Stream.onDemand.url)
        )
        expectEqualPublished(
            values: [Stream.onDemand.url, Stream.shortOnDemand.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .milliseconds(100)
        ) {
            player.replaceCurrentItem(with: .init(url: Stream.shortOnDemand.url))
        }
    }

    func testSmoothCurrentItemWhenRemovingCurrentItemWithNextItem() {
        let player = AVQueuePlayer(
            items: [
                .init(url: Stream.shortOnDemand.url),
                .init(url: Stream.onDemand.url)
            ]
        )
        expectEqualPublished(
            values: [Stream.shortOnDemand.url, Stream.onDemand.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .milliseconds(100)
        ) {
            player.remove(player.items().first!)
        }
    }

    func testSmoothCurrentItemWhenRemovingAllItems() {
        let player = AVQueuePlayer(
            playerItem: .init(url: Stream.shortOnDemand.url)
        )
        expectEqualPublished(
            values: [Stream.shortOnDemand.url],
            from: player.smoothCurrentItemPublisher().map(\.?.url),
            during: .milliseconds(100)
        ) {
            player.removeAllItems()
        }
    }
}
