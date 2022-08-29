//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemStatePublisherTests: XCTestCase {
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    func testEmpty() {
        let player = AVPlayer()
        expectPublished(
            values: [.unknown],
            from: player.itemStatePublisher(),
            during: 2
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.unknown, .readyToPlay],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: player.itemStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testUnavailableStream() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testResourceLoadingFailure() {
        let asset = AVURLAsset(url: TestStreams.customUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: queue)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }
}

final class ItemStatePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            // The second item can be pre-buffered and is immediately ready
            values: [.unknown, .readyToPlay, .ended, .readyToPlay, .ended],
            from: player.itemStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            // The third item cannot be pre-buffered and goes through the usual states
            values: [
                .unknown, .readyToPlay, .ended,
                .failed(error: TestError.any),
                .unknown, .readyToPlay, .ended
            ],
            from: player.itemStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }
}

final class PlaybackStatePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectPublished(values: [.idle], from: player.playbackStatePublisher(), during: 2)
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(values: [.idle, .paused], from: player.playbackStatePublisher(), during: 2)
    }

    func testPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(values: [.idle, .playing], from: player.playbackStatePublisher(), during: 2) {
            player.play()
        }
    }

    func testPlayPause() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
        expectPublishedNext(values: [.paused], from: player.playbackStatePublisher(), during: 2) {
            player.pause()
        }
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.idle, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testPlaybackFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.idle, .failed(error: TestError.any)],
            from: player.playbackStatePublisher(),
            during: 2
        )
    }
}

final class PlaybackStatePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            // The second item can be pre-buffered and is immediately played
            values: [.idle, .playing, .ended, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            // The third item cannot be pre-buffered and goes through the usual states
            values: [
                .idle, .playing, .ended,
                .failed(error: TestError.any),
                .idle, .playing, .ended
            ],
            from: player.playbackStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }
}

final class ItemDurationPublisherTests: XCTestCase {
    func testDuration() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.indefinite, CMTime(value: 120, timescale: 1)],
            from: player.itemDurationPublisher(),
            to: beClose(within: 0.5)
        )
    }
}

final class ItemDurationPublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                .indefinite,
                CMTime(value: 1, timescale: 1),
                // Next media can be prepared and is immediately ready
                CMTime(value: 120, timescale: 1)
            ],
            from: player.itemDurationPublisher()
                .removeDuplicates(by: CMTime.close(within: 0.5)),
            to: beClose(within: 0.5),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            values: [
                .indefinite,
                CMTime(value: 1, timescale: 1),
                // Next media cannot be prepared because of the failure
                .indefinite,
                CMTime(value: 120, timescale: 1)
            ],
            from: player.itemDurationPublisher()
                .removeDuplicates(by: CMTime.close(within: 0.5)),
            to: beClose(within: 0.5),
            during: 4
        ) {
            player.play()
        }
    }
}

final class ItemTimeRangePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectPublished(
            values: [],
            from: player.itemTimeRangePublisher(),
            during: 2
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [CMTimeRange(start: .zero, duration: CMTime(value: 120, timescale: 1))],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 0.5)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.zero],
            from: player.itemTimeRangePublisher()
        )
    }
}

final class ItemTimeRangePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                CMTimeRange(start: .zero, duration: CMTime(value: 1, timescale: 1)),
                CMTimeRange(start: .zero, duration: CMTime(value: 120, timescale: 1))
            ],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 0.5),
            during: 3
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            values: [
                CMTimeRange(start: .zero, duration: CMTime(value: 1, timescale: 1)),
                CMTimeRange(start: .zero, duration: CMTime(value: 120, timescale: 1))
            ],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 0.5),
            during: 3
        ) {
            player.play()
        }
    }
}

// TODO: Current time publisher tests

final class PulsePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectSimilarPublished(
            values: [],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 2
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [
                Pulse(time: .zero, timeRange: .zero, itemDuration: .indefinite),
                Pulse(time: CMTime(value: 1, timescale: 1), timeRange: .zero, itemDuration: .indefinite),
                Pulse(time: CMTime(value: 2, timescale: 1), timeRange: .zero, itemDuration: .indefinite)
            ],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main)
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 2
        ) {
            player.play()
        }
    }
}
