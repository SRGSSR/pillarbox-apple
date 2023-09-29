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

final class QueuePlayerBufferingPublisherTests: TestCase {
    private func bufferingPublisher(for player: QueuePlayer) -> AnyPublisher<Bool, Never> {
        player.propertiesPublisher()
            .map(\.isBuffering)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testBufferingEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [false],
            from: bufferingPublisher(for: player)
        )
    }

    func testBuffering() {
        let player = QueuePlayer(playerItem: .init(url: Stream.onDemand.url))
        expectAtLeastEqualPublished(
            values: [true, false],
            from: bufferingPublisher(for: player)
        )
    }
}
