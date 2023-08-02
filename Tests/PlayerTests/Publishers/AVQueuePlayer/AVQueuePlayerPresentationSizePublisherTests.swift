//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Streams
import XCTest

// swiftlint:disable:next type_name
final class AVQueuePlayerPresentationSizePublisherTests: TestCase {
    func testVideoFollowedByAudio() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.mp3.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), nil, .zero],
            from: player.presentationSizePublisher()
        ) {
            player.play()
        }
    }

    func testVideosWithDifferentSizes() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.croppedOnDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), CGSize(width: 360, height: 360)],
            from: player.presentationSizePublisher()
        ) {
            player.play()
        }
    }

    func testVideosWithIdenticalSizes() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            values: [nil, CGSize(width: 640, height: 360)],
            from: player.presentationSizePublisher(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectAtLeastEqualPublished(
            values: [nil, CGSize(width: 640, height: 360), nil, CGSize(width: 640, height: 360)],
            from: player.presentationSizePublisher()
        ) {
            player.play()
        }
    }
}
