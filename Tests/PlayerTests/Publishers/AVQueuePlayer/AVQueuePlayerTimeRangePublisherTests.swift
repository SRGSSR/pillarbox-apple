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

final class AVQueuePlayerTimeRangePublisherTests: TestCase {
    private static func seekableTimeRangePublisher(for player: AVQueuePlayer) -> AnyPublisher<CMTimeRange, Never> {
        player.timePropertiesPublisher()
            .map(\.seekableTimeRange)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = AVQueuePlayer()
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: Self.seekableTimeRangePublisher(for: player)
        )
    }

    func testItemLifeCycle() {
        let player = AVQueuePlayer(
            playerItem: .init(url: Stream.shortOnDemand.url)
        )
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: Self.seekableTimeRangePublisher(for: player),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }
}
