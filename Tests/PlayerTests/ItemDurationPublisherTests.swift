//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemDurationPublisherTests: XCTestCase {
    func testDuration() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.indefinite, CMTime(value: 120, timescale: 1)],
            from: player.itemDurationPublisher(),
            to: beClose(within: 0.5)
        )
    }
}
