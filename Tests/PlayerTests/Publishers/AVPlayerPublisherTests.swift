//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Streams

final class AVPlayerPublisherTests: TestCase {
    private static func errorPublisher(for player: AVPlayer) -> AnyPublisher<Error?, Never> {
        player.errorPublisher()
            .removeDuplicates { $0 as? NSError == $1 as? NSError }
            .eraseToAnyPublisher()
    }

    private static func seekableTimeRangePublisher(for player: AVPlayer) -> AnyPublisher<CMTimeRange, Never> {
        player.timePropertiesPublisher()
            .map(\.seekableTimeRange)
            .removeDuplicates()
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
        expectPublished(
            values: [nil, PlayerError.resourceNotFound],
            from: Self.errorPublisher(for: player),
            to: beEqual,
            during: .milliseconds(500)
        )
    }

    func testTimeRangeEmpty() {
        let player = AVQueuePlayer()
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: Self.seekableTimeRangePublisher(for: player)
        )
    }

    func testTimeRangeLifeCycle() {
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
