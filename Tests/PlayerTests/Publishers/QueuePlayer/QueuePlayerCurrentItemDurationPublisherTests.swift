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
final class QueuePlayerCurrentItemDurationPublisherTests: TestCase {
    private func itemDurationPublisher(for player: QueuePlayer) -> AnyPublisher<CMTime, Never> {
        player.propertiesPublisher()
            .map(\.itemProperties.duration)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastPublished(
            values: [.invalid],
            from: itemDurationPublisher(for: player),
            to: beClose(within: 1)
        )
    }

    func testDuration() {
        let player = QueuePlayer(playerItem: .init(url: Stream.shortOnDemand.url))
        expectAtLeastPublished(
            values: [.invalid, Stream.shortOnDemand.duration, .invalid],
            from: itemDurationPublisher(for: player),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }
}
