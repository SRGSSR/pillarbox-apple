//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

final class ItemMediaTypePublisherTests: TestCase {
    func testUnknown() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown], from: item.mediaTypePublisher())
    }

    func testAudio() {
        let item = AVPlayerItem(url: Stream.mp3.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.audio], from: item.mediaTypePublisher())
    }

    func testVideo() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.video], from: item.mediaTypePublisher())
    }

    func testAudioAndVideo() {
        let item1 = AVPlayerItem(url: Stream.mp3.url)
        let item2 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])

        expectAtLeastEqualPublished(values: [.audio], from: item1.mediaTypePublisher()) {
            player.play()
        }

        expectAtLeastEqualPublished(values: [.video], from: item2.mediaTypePublisher())
    }
}
