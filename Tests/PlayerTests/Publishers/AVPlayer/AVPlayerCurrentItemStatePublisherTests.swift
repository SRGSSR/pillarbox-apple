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

final class AVPlayerCurrentItemStatePublisherTests: TestCase {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()

    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: player.currentItemStatePublisher()
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay],
            from: player.currentItemStatePublisher()
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: player.currentItemStatePublisher()
        ) {
            player.play()
        }
    }

    func testUnavailableStream() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [
                .unknown,
                .failed(error: PlayerError.resourceNotFound)
            ],
            from: player.currentItemStatePublisher()
        )
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: Stream.corruptOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [
                .unknown,
                .failed(error: PlayerError.segmentNotFound)
            ],
            from: player.currentItemStatePublisher()
        )
    }

    func testResourceLoadingFailure() {
        let asset = AVURLAsset(url: Stream.custom.url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global())
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
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
            from: player.currentItemStatePublisher()
        )
    }
}
