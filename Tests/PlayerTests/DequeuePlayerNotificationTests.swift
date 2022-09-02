//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

@MainActor
final class DequeuePlayerNotificationTests: XCTestCase {
    func testSeekAsyncBeforePlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).to(beEmpty())
                let success = await player.seek(
                    to: CMTime(value: 2, timescale: 1),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero
                )
                expect(success).to(beTrue())
            }
        }
    }

    func testSeekAsyncDuringPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).notTo(beEmpty())
                let success = await player.seek(
                    to: CMTime(value: 2, timescale: 1),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero
                )
                expect(success).to(beTrue())
            }
        }
    }

    func testSeekWithCompletionHandlerBeforePlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).to(beEmpty())
            player.seek(to: CMTime(value: 2, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testSeekWithCompletionHandlerDuringPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).notTo(beEmpty())
            player.seek(to: CMTime(value: 2, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testMultipleSeeksAsyncBeforePlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player),
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).to(beEmpty())

                let success1 = await player.seek(
                    to: CMTime(value: 1, timescale: 2),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero
                )
                expect(success1).to(beTrue())

                let success2 = await player.seek(
                    to: CMTime(value: 2, timescale: 2),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero
                )
                expect(success2).to(beTrue())
            }
        }
    }

    func testMultipleSeeksAsyncDuringPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).notTo(beEmpty())

                async let seek1 = player.seek(
                    to: CMTime(value: 1, timescale: 2),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero
                )
                async let seek2 = player.seek(
                    to: CMTime(value: 2, timescale: 2),
                    toleranceBefore: .zero,
                    toleranceAfter: .zero
                )
                let (success1, success2) = await (seek1, seek2)
                expect(success1).to(beFalse())
                expect(success2).to(beTrue())
            }
        }
    }

    func testMultipleSeeksWithCompletionHandlerBeforePlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player),
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).to(beEmpty())

            player.seek(to: CMTime(value: 1, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: CMTime(value: 2, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testMultipleSeeksWithCompletionHandlerDuringPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }
        expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).notTo(beEmpty())

            player.seek(to: CMTime(value: 1, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: CMTime(value: 2, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }
}
