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

// swiftlint:disable:next type_name
final class QueuePlayerCurrentItemStatePublisherTests: TestCase {
    // swiftlint:disable:next weak_delegate
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()

    private func currentItemStatePublisher(for player: QueuePlayer) -> AnyPublisher<ItemState, Never> {
        player.propertiesPublisher()
            .map(\.itemProperties.state)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [.unknown],
            from: currentItemStatePublisher(for: player)
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay],
            from: currentItemStatePublisher(for: player)
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: currentItemStatePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testUnavailableStream() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = QueuePlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown
            ],
            from: currentItemStatePublisher(for: player),
            during: .seconds(1)
        )
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: Stream.corruptOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown
            ],
            from: currentItemStatePublisher(for: player),
            during: .seconds(1)
        )
    }

    func testResourceLoadingFailure() {
        let asset = AVURLAsset(url: Stream.custom.url)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: .global())
        let item = AVPlayerItem(asset: asset)
        let player = QueuePlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .unknown
            ],
            from: currentItemStatePublisher(for: player),
            during: .seconds(1)
        )
    }
}
