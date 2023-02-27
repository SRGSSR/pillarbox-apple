//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemStreamTypePublisherTests: TestCase {
    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .onDemand],
            from: item.streamTypePublisher(),
            during: 2
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .live],
            from: item.streamTypePublisher(),
            during: 2
        )
    }

    func testDVR() {
        let item = AVPlayerItem(url: Stream.dvr.url)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .dvr],
            from: item.streamTypePublisher(),
            during: 2
        )
    }
}
