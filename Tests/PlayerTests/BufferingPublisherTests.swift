//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class BufferingPublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [false],
            from: player.bufferingPublisher(),
            during: 2
        )
    }

    func testLoaded() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        )
    }

    func testFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        )
    }
}
