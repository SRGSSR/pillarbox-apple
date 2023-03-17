//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

final class MediaTypeTests: TestCase {
    func testUnknown() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(values: [.unknown], from: player.mediaTypePublisher())
    }

    func testAudio() {
    }

    func testVideo() {
    }
}
