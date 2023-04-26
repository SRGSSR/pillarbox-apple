//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Streams
import XCTest

final class AVPlayerItemDurationPublisherTests: TestCase {
    func testDuration() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, Stream.onDemand.duration],
            from: item.durationPublisher(),
            to: beClose(within: 1)
        )
    }
}
