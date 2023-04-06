//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

final class AVPlayerItemPresentationSizePublisherTests: TestCase {
    func testUnknown() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [nil], from: item.presentationSizePublisher())
    }

    func testAudio() {
        let item = AVPlayerItem(url: Stream.mp3.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [nil, .zero], from: item.presentationSizePublisher())
    }

    func testVideo() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [nil, CGSize(width: 640, height: 426)], from: item.presentationSizePublisher())
    }
}
