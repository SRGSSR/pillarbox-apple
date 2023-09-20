//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import Streams

// swiftlint:disable:next type_name
final class AVPlayerItemPresentationSizePublisherTests: TestCase {
    func testAudio() {
        let item = AVPlayerItem(url: Stream.mp3.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.zero], from: item.presentationSizePublisher())
    }

    func testVideo() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.zero, CGSize(width: 640, height: 360)], from: item.presentationSizePublisher())
    }
}
