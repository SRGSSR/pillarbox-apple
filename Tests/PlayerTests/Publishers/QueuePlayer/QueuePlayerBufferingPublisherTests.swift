//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Streams
import XCTest

final class QueuePlayerBufferingPublisherTests: TestCase {
    private func bufferingPublisher(for player: QueuePlayer) -> AnyPublisher<Bool, Never> {
        player.propertiesPublisher()
            .map(\.itemProperties.isBuffering)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [false],
            from: bufferingPublisher(for: player)
        )
    }

    func testLoaded() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [true, false],
            from: bufferingPublisher(for: player)
        )
    }

    func testFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [true, false],
            from: bufferingPublisher(for: player)
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [true, false],
            from: bufferingPublisher(for: player)
        ) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(
            values: [true, false],
            from: bufferingPublisher(for: player)
        ) {
            player.seek(
                to: CMTime(value: 10, timescale: 1),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            ) { _ in }
        }
    }
}
