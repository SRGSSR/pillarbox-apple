//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Streams
import XCTest

final class AVPlayerCurrentItemStatePublisherTests: TestCase {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()

    private func currentItemStatePublisher(for player: AVPlayer) -> AnyPublisher<ItemState, Never> {
        player.contextPublisher()
            .map(\.currentItemContext.state)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: currentItemStatePublisher(for: player)
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay],
            from: currentItemStatePublisher(for: player)
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: currentItemStatePublisher(for: player)
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
            from: currentItemStatePublisher(for: player)
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
            from: currentItemStatePublisher(for: player)
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
            from: currentItemStatePublisher(for: player)
        )
    }
}
