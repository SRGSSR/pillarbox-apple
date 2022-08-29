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
