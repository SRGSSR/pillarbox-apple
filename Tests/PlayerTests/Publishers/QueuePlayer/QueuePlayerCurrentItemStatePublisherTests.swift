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
final class QueuePlayerCurrentItemStatePublisherTests: TestCase {
    private func itemStatePublisher(for player: QueuePlayer) -> AnyPublisher<ItemState, Never> {
        player.propertiesPublisher()
            .map(\.itemProperties.state)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: itemStatePublisher(for: player)
        )
    }

    func testStateLifeCycle() {
        let player = QueuePlayer(
            playerItem: .init(url: Stream.shortOnDemand.url)
        )
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended, .unknown],
            from: itemStatePublisher(for: player)
        ) {
            player.play()
        }
    }
}
