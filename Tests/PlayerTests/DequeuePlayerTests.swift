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
    func testSeekAsyncBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        let targetTime = CMTime(value: 2, timescale: 1)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).to(beEmpty())
                let success = await player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success).to(beTrue())
            }
        }
    }

    func testSeekAsyncDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        try expectPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }

        let targetTime = CMTime(value: 2, timescale: 1)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).notTo(beEmpty())
                let success = await player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success).to(beTrue())
            }
        }
    }

    func testSeekWithCompletionHandlerBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        let targetTime = CMTime(value: 2, timescale: 1)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).to(beEmpty())
            player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testSeekWithCompletionHandlerDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        try expectPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }

        let targetTime = CMTime(value: 2, timescale: 1)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).notTo(beEmpty())
            player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testMultipleSeeksAsyncBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)

        let targetTime1 = CMTime(value: 1, timescale: 2)
        let targetTime2 = CMTime(value: 2, timescale: 2)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime1
                ]),
                Notification(name: .didSeek, object: player),
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime2
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).to(beEmpty())

                let success1 = await player.seek(to: targetTime1, toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success1).to(beTrue())

                let success2 = await player.seek(to: targetTime2, toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success2).to(beTrue())
            }
        }
    }

    func testMultipleSeeksAsyncDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        try expectPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }

        let targetTime1 = CMTime(value: 1, timescale: 2)
        let targetTime2 = CMTime(value: 2, timescale: 2)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime1
                ]),
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime2
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            Task {
                expect(item.loadedTimeRanges).notTo(beEmpty())

                async let seek1 = player.seek(to: targetTime1, toleranceBefore: .zero, toleranceAfter: .zero)
                async let seek2 = player.seek(to: targetTime2, toleranceBefore: .zero, toleranceAfter: .zero)
                let (success1, success2) = await (seek1, seek2)
                expect(success1).to(beFalse())
                expect(success2).to(beTrue())
            }
        }
    }

    func testMultipleSeeksWithCompletionHandlerBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        let targetTime1 = CMTime(value: 1, timescale: 2)
        let targetTime2 = CMTime(value: 2, timescale: 2)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime1
                ]),
                Notification(name: .didSeek, object: player),
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime2
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).to(beEmpty())

            player.seek(to: targetTime1, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: targetTime2, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testMultipleSeeksWithCompletionHandlerDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = DequeuePlayer(playerItem: item)
        try expectPublished(values: [.unknown, .readyToPlay], from: item.publisher(for: \.status)) {
            player.play()
        }

        let targetTime1 = CMTime(value: 1, timescale: 2)
        let targetTime2 = CMTime(value: 2, timescale: 2)
        try expectReceived(
            notifications: [
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime1
                ]),
                Notification(name: .willSeek, object: player, userInfo: [
                    DequeuePlayer.SeekInfoKey.targetTime: targetTime2
                ]),
                Notification(name: .didSeek, object: player)
            ],
            for: [.willSeek, .didSeek],
            object: player
        ) {
            expect(item.loadedTimeRanges).notTo(beEmpty())

            player.seek(to: targetTime1, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: targetTime2, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }
}
