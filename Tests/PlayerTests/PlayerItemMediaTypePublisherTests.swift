//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

final class PlayerItemMediaTypePublisherTests: TestCase {
    func testUnknown() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown], from: item.mediaTypePublisher())
    }

    func testAudio() {
        let item = AVPlayerItem(url: Stream.mp3.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown, .audio], from: item.mediaTypePublisher())
    }

    func testVideo() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown, .video], from: item.mediaTypePublisher())
    }
}
