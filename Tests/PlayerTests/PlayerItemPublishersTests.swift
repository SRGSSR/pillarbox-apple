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

final class PlayerItemPublishersTests: XCTestCase {
    func testValidItemStateWithoutPlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .readyToPlay],
            from: item.itemStatePublisher(),
            during: 2
        )
    }

    func testValidItemStateWithPlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: item.itemStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: item.itemStatePublisher(),
            during: 2
        )
    }
}
