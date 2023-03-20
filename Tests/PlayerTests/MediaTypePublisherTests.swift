//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

final class MediaTypePublisherTests: TestCase {
    func testUnknown() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(values: [.unknown], from: player.mediaTypePublisher())
    }

    func testAudio() {
        let player = AVPlayer(url: Stream.mp3.url)
        expectAtLeastEqualPublished(values: [.audio], from: player.mediaTypePublisher())
    }

    func testVideo() {
        let player = AVPlayer(url: Stream.shortOnDemand.url)
        expectAtLeastEqualPublished(values: [.video], from: player.mediaTypePublisher())
    }
}
