//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Streams

// swiftlint:disable:next type_name
final class QueuePlayerPresentationSizePublisherTests: TestCase {
    private func presentationSizePublisher(for player: QueuePlayer) -> AnyPublisher<CGSize?, Never> {
        player.propertiesPublisher()
            .map(\.itemProperties.presentationSize)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testUnknown() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(values: [nil], from: presentationSizePublisher(for: player))
    }

    func testAudio() {
        let player = QueuePlayer(url: Stream.mp3.url)
        expectAtLeastEqualPublished(values: [nil, .zero], from: presentationSizePublisher(for: player))
    }

    func testVideo() {
        let player = QueuePlayer(url: Stream.shortOnDemand.url)
        expectAtLeastEqualPublished(values: [nil, CGSize(width: 640, height: 360)], from: presentationSizePublisher(for: player))
    }

    func testVideoFollowedByAudio() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.mp3.url)
        let player = QueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), nil, .zero],
            from: presentationSizePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testVideosWithDifferentSizes() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.squareOnDemand.url)
        let player = QueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), CGSize(width: 360, height: 360)],
            from: presentationSizePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testVideosWithIdenticalSizes() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(items: [item1, item2])
        expectEqualPublished(
            values: [nil, CGSize(width: 640, height: 360)],
            from: presentationSizePublisher(for: player),
            during: .seconds(2)
        ) {
            player.play()
        }
    }
}
