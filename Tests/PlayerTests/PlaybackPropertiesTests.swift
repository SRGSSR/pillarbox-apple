//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class SingleItemPublisherTests: XCTestCase {
    func testOnDemand() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [
                PlaybackProperties(
                    pulse: Pulse(
                        time: .zero,
                        timeRange: CMTimeRange(
                            start: .zero,
                            duration: CMTime(value: 1, timescale: 1)
                        ),
                        itemDuration: CMTime(value: 1, timescale: 1)
                    ),
                    targetTime: nil
                )
            ],
            from: PlaybackProperties.publisher(for: player, interval: CMTime(value: 1, timescale: 1))
        )
    }
}
