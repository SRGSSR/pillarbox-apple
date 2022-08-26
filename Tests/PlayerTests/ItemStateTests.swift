//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import XCTest

final class MultipleItemStatePublisherTests: XCTestCase {
    func testChainedShortItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        try expectPublished(
            // The second item can be pre-buffered and is immediately ready
            values: [.unknown, .readyToPlay, .ended, .readyToPlay, .ended],
            from: ItemState.publisher(for: player),
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
            from: ItemState.publisher(for: player),
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
            from: ItemState.publisher(for: player),
            during: 2
        )
    }

    func testValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: ItemState.publisher(for: player),
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
            from: ItemState.publisher(for: player),
            during: 1
        )
    }

    func testCorruptStream() throws {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: ItemState.publisher(for: player),
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
            from: ItemState.publisher(for: player),
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
            from: ItemState.publisher(for: player),
            during: 1
        )
    }
}
