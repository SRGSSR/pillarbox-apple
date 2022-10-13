//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness
@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class PlayerItemTests: XCTestCase {
    func testPlayback() {
        let item = PlayerItem(urn: "urn:srf:video:2fde31db-e9a7-4233-a9eb-06ec19f18ba9")
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
    }

    func testFailure() {
        let item = PlayerItem(urn: "invalid")
        let player = AVPlayer(playerItem: item)
        expectAtLeastSimilarPublished(values: [.idle, .failed(error: TestError.any)], from: player.playbackStatePublisher()) {
            player.play()
        }
    }
}
