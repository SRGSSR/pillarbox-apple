//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class SingleItemPulsePublisherTests: XCTestCase {
    func testOnDemandPulse() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                )
            ],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 4
        ) {
            player.play()
        }
    }

    func testLivePulse() throws {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
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

    func testFailedPlaybackPulse() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 2
        ) {
            player.play()
        }
    }

    func testNonPlayingPulse() throws {
        let player = AVPlayer()
        try expectPublished(
            values: [],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 2
        ) {
            player.play()
        }
    }
}

final class MultipleItemPulsePublisherTests: XCTestCase {
    func testChainedShortItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        try expectPublished(
            values: [
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                )
            ],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 4
        ) {
            player.play()
        }
    }

    func testChainedItemsWithFailure() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        try expectPublished(
            values: [
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    ),
                    itemDuration: CMTime(value: 1, timescale: 1)
                )
            ],
            from: player.pulsePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 4
        ) {
            player.play()
        }
    }
}

final class MultipleItemStatePublisherTests: XCTestCase {
    func testChainedShortItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        try expectPublished(
            // The second item can be pre-buffered and is immediately ready
            values: [.unknown, .readyToPlay, .ended, .readyToPlay, .ended],
            from: player.itemStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }

    func testChainedItemsWithFailure() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        try expectPublished(
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

final class SingleItemStatePublisherTests: XCTestCase {
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    func testNoPlayback() throws {
        let player = AVPlayer()
        try expectPublished(
            values: [.unknown],
            from: player.itemStatePublisher(),
            during: 2
        )
    }

    func testValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: player.itemStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testUnavailableStream() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testCorruptStream() throws {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: player.itemStatePublisher(),
            during: 1
        )
    }

    func testResourceLoadingFailure() throws {
        let asset = AVURLAsset(url: TestStreams.customUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: queue)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: player.itemStatePublisher(),
            during: 1
        ) {
            player.play()
        }
    }

    func testNonPlayingValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .readyToPlay],
            from: player.itemStatePublisher(),
            during: 1
        )
    }
}

final class SingleItemPublisherTests: XCTestCase {
    func testOnDemand() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [
                PlaybackProperties(
                    pulse: Pulse(
                        time: .zero,
                        timeRange: CMTimeRange(
                            start: .zero,
                            duration: CMTime(value: 1, timescale: 1)
                        ),
                        itemDuration: CMTime(value: 1, timescale: 1)
                    ),
                    targetTime: nil
                )
            ],
            from: player.playbackPropertiesPublisher(interval: CMTime(value: 1, timescale: 1))
        )
    }
}

final class MultipleItemPlaybackStateTests: XCTestCase {
    func testChainedShortItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        try expectPublished(
            // The second item can be pre-buffered and is immediately played
            values: [.idle, .playing, .ended, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }

    func testChainedItemsWithFailure() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        try expectPublished(
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

final class SingleItemPlaybackStateTests: XCTestCase {
    func testPlaybackStartWithoutPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .paused], from: player.playbackStatePublisher(), during: 2)
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .playing], from: player.playbackStatePublisher(), during: 2) {
            player.play()
        }
    }

    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
        try expectPublishedNext(values: [.paused], from: player.playbackStatePublisher(), during: 2) {
            player.pause()
        }
    }

    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.idle, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.idle, .failed(error: TestError.any)],
            from: player.playbackStatePublisher(),
            during: 2
        )
    }

    func testWithoutItems() throws {
        let player = AVPlayer()
        try expectPublished(values: [.idle], from: player.playbackStatePublisher(), during: 2)
    }
}
