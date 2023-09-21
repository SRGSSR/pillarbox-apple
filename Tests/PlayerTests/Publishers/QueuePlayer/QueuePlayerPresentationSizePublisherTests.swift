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
        player.contextPublisher()
            .map(\.currentItemContext.presentationSize)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testUnknown() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(values: [nil], from: presentationSizePublisher(for: player))
    }

    func testAudio() {
        let player = QueuePlayer(url: Stream.mp3.url)
        expectAtLeastEqualPublished(values: [nil, .zero], from: presentationSizePublisher(for: player))
    }

    func testVideo() {
        let player = QueuePlayer(url: Stream.shortOnDemand.url)
        expectAtLeastEqualPublished(values: [nil, CGSize(width: 640, height: 360)], from: presentationSizePublisher(for: player))
    }
}
