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
import XCTest

// swiftlint:disable:next type_name
final class AVPlayerCurrentItemDurationPublisherTests: TestCase {
    private func currentItemDurationPublisher(for player: AVPlayer) -> AnyPublisher<CMTime, Never> {
        player.contextPublisher()
            .map(\.currentItemContext.duration)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testDuration() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, Stream.onDemand.duration],
            from: currentItemDurationPublisher(for: player),
            to: beClose(within: 1)
        )
    }
}
