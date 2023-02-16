//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class StreamTypePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: player.streamTypePublisher()
        )
    }

    func testOnDemand() {
        let player = AVPlayer(url: Stream.onDemand.url)
        expectAtLeastEqualPublished(
            values: [.unknown, .onDemand],
            from: player.streamTypePublisher()
        )
    }

    func testLive() {
        let player = AVPlayer(url: Stream.live.url)
        expectAtLeastEqualPublished(
            values: [.unknown, .live],
            from: player.streamTypePublisher()
        )
    }

    func testDVR() {
        let player = AVPlayer(url: Stream.dvr.url)
        expectAtLeastEqualPublished(
            values: [.unknown, .dvr],
            from: player.streamTypePublisher()
        )
    }
}
