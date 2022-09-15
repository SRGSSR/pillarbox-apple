//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemTimeRangePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [],
            from: player.itemTimeRangePublisher(configuration: PlayerConfiguration()),
            during: 2
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: TestStreams.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [CMTimeRange(start: .zero, duration: TestStreams.onDemand.duration)],
            from: player.itemTimeRangePublisher(configuration: PlayerConfiguration()),
            to: beClose(within: 1)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: TestStreams.live.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.zero],
            from: player.itemTimeRangePublisher(configuration: PlayerConfiguration())
        )
    }
}
