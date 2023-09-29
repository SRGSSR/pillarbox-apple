//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Streams

final class AVQueuePlayerErrorPublisherTests: TestCase {
    private static func errorPublisher(for player: AVPlayer) -> AnyPublisher<Error?, Never> {
        player.errorPublisher()
            .removeDuplicates { $0 as? NSError == $1 as? NSError }
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = AVQueuePlayer()
        expectAtLeastPublished(
            values: [nil],
            from: Self.errorPublisher(for: player),
            to: beEqual
        )
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
}
