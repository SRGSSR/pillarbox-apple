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

// swiftlint:disable:next type_name
final class QueuePlayerCurrentItemDurationPublisherTests: TestCase {
    private func currentItemDurationPublisher(for player: QueuePlayer) -> AnyPublisher<CMTime, Never> {
        player.contextPublisher()
            .map(\.currentItemContext.duration)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testDuration() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, Stream.onDemand.duration],
            from: currentItemDurationPublisher(for: player),
            to: beClose(within: 1)
        )
    }
    
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(items: [item1, item2])
        expectAtLeastPublished(
            values: [
                .invalid,
                Stream.shortOnDemand.duration,
                // Next media can be prepared and is immediately ready
                Stream.onDemand.duration
            ],
            from: currentItemDurationPublisher(for: player),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }
}
