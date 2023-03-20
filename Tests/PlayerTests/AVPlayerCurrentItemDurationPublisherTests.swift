//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class AVPlayerCurrentItemDurationPublisherTests: TestCase {
    func testDuration() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, Stream.onDemand.duration],
            from: player.currentItemDurationPublisher(),
            to: beClose(within: 1)
        )
    }
}
