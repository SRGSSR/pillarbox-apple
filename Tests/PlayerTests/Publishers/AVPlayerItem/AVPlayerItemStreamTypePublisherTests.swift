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

final class AVPlayerItemStreamTypePublisherTests: TestCase {
    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .onDemand],
            from: item.streamTypePublisher()
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .live],
            from: item.streamTypePublisher()
        )
    }

    func testDVR() {
        let item = AVPlayerItem(url: Stream.dvr.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .dvr],
            from: item.streamTypePublisher()
        )
    }
}
