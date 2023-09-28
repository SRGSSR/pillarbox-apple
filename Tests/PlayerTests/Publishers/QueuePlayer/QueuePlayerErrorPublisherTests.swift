//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Streams

final class QueuePlayerErrorPublisherTests: TestCase {
    func testError() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(items: [item1, item2, item3])
        let publisher = player.errorPublisher()
            .removeDuplicates { $0 as? NSError == $1 as? NSError }

        expectAtLeastPublished(
            values: [nil, PlayerError.resourceNotFound, nil],
            from: publisher,
            to: beEqual
        ) {
            player.play()
        }
    }
}
