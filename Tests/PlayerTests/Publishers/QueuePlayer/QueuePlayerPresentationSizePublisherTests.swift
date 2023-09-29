//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Streams

// swiftlint:disable:next type_name
final class QueuePlayerPresentationSizePublisherTests: TestCase {
    private func presentationSizePublisher(for player: QueuePlayer) -> AnyPublisher<CGSize?, Never> {
        player.propertiesPublisher()
            .map(\.itemProperties.presentationSize)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [nil],
            from: presentationSizePublisher(for: player)
        )
    }

    func testPresentationSize() {
        let player = QueuePlayer(url: Stream.shortOnDemand.url)
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), nil],
            from: presentationSizePublisher(for: player)
        ) {
            player.play()
        }
    }
}
