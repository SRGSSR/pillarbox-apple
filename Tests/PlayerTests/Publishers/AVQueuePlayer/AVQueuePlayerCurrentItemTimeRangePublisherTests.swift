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

// swiftlint:disable:next type_name
final class AVQueuePlayerCurrentItemTimeRangePublisherTests: TestCase {
    private func currentItemTimeRangePublisher(for player: AVQueuePlayer) -> AnyPublisher<CMTimeRange, Never> {
        player.timePropertiesPublisher()
            .map(\.seekableTimeRange)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testItemLifeCycle() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: currentItemTimeRangePublisher(for: player),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }
}
