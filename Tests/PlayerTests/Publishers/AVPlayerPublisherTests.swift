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
            during: .seconds(2)
        )
    }
}
