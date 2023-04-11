//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation

final class AVPlayerPresentationSizePublisherTests: TestCase {
    func testUnknown() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(values: [nil], from: player.presentationSizePublisher())
    }

    func testAudio() {
        let player = AVPlayer(url: Stream.mp3.url)
        expectAtLeastEqualPublished(values: [nil, .zero], from: player.presentationSizePublisher())
    }

    func testVideo() {
        let player = AVPlayer(url: Stream.shortOnDemand.url)
        expectAtLeastEqualPublished(values: [nil, CGSize(width: 640, height: 426)], from: player.presentationSizePublisher())
    }
}
