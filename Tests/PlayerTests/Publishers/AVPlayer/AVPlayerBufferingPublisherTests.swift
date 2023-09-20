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

final class AVPlayerBufferingPublisherTests: TestCase {
    private func bufferingPublisher(for player: AVPlayer) -> AnyPublisher<Bool, Never> {
        player.contextPublisher()
            .map(\.currentItemContext.isBuffering)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [false],
            from: bufferingPublisher(for: player)
        )
    }

    func testLoaded() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: bufferingPublisher(for: player)
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: bufferingPublisher(for: player)
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: bufferingPublisher(for: player)
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: bufferingPublisher(for: player)
        ) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(
            values: [true, false],
            from: bufferingPublisher(for: player)
        ) {
            player.seek(
                to: CMTime(value: 10, timescale: 1),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            ) { _ in }
        }
    }
}
