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
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()

    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [.unknown],
            from: player.currentItemStatePublisher(),
            during: 2
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .readyToPlay],
            from: player.currentItemStatePublisher(),
            during: 1
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: player.currentItemStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testUnavailableStream() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown,
                .failed(error: PlayerError.resourceNotFound)
            ],
            from: player.currentItemStatePublisher(),
            during: 1
        )
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: Stream.corruptOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown,
                .failed(error: PlayerError.segmentNotFound)
            ],
            from: player.currentItemStatePublisher(),
            during: 1
        )
    }

    func testResourceLoadingFailure() {
        let asset = AVURLAsset(url: Stream.custom.url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global())
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown,
                .failed(error: NSError(
                    domain: "PlayerTests.ResourceLoaderError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to load the resource (custom message)"
                    ]
                ))
            ],
            from: player.currentItemStatePublisher(),
            during: 1
        )
    }
}
