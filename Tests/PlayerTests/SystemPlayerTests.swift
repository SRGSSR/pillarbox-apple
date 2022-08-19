//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Nimble
import XCTest

final class SystemPlayerTests: XCTestCase {
    func testSeekAsyncBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectNotifications(
            [.willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
        ) {
            Task {
                expect(item.loadedTimeRanges).to(beEmpty())
                let success = await player.seek(to: CMTime(value: 2, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success).to(beTrue())
            }
        }
    }

    func testSeekAsyncDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectPublisher(item.publisher(for: \.status), values: [.unknown, .readyToPlay]) {
            player.play()
        }

        try expectNotifications(
            [.willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
        ) {
            Task {
                expect(item.loadedTimeRanges).notTo(beEmpty())
                let success = await player.seek(to: CMTime(value: 2, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success).to(beTrue())
            }
        }
    }

    func testSeekWithCompletionBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectNotifications(
            [.willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
        ) {
            expect(item.loadedTimeRanges).to(beEmpty())
            player.seek(to: CMTime(value: 2, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testSeekWithCompletionDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectPublisher(item.publisher(for: \.status), values: [.unknown, .readyToPlay]) {
            player.play()
        }

        try expectNotifications(
            [.willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
        ) {
            expect(item.loadedTimeRanges).notTo(beEmpty())
            player.seek(to: CMTime(value: 2, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                expect(finished).to(beTrue())
            }
        }
    }

    func testMultipleSeeksAsyncBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectNotifications(
            [.willSeek, .didSeek, .willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player),
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
        ) {
            Task {
                expect(item.loadedTimeRanges).to(beEmpty())

                let success1 = await player.seek(to: CMTime(value: 1, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success1).to(beTrue())

                let success2 = await player.seek(to: CMTime(value: 2, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero)
                expect(success2).to(beTrue())
            }
        }
    }

    func testMultipleSeeksAsyncDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectPublisher(item.publisher(for: \.status), values: [.unknown, .readyToPlay]) {
            player.play()
        }

        try expectNotifications(
            [.willSeek, .willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
        ) {
            Task {
                expect(item.loadedTimeRanges).notTo(beEmpty())

                async let seek1 = player.seek(to: CMTime(value: 1, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero)
                async let seek2 = player.seek(to: CMTime(value: 2, timescale: 2), toleranceBefore: .zero, toleranceAfter: .zero)
                let (success1, success2) = await (seek1, seek2)
                expect(success1).to(beFalse())
                expect(success2).to(beTrue())
            }
        }
    }

    func testMultipleSeeksWithCompletionBeforePlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectNotifications(
            [.willSeek, .didSeek, .willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player),
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
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

    func testMultipleSeeksWithCompletionDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = SystemPlayer(playerItem: item)
        try expectPublisher(item.publisher(for: \.status), values: [.unknown, .readyToPlay]) {
            player.play()
        }

        try expectNotifications(
            [.willSeek, .willSeek, .didSeek],
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .willSeek, object: player),
                Notification(name: .didSeek, object: player)
            ]
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

    // TODO:
    //  - Test without media (no events; requires a way to check that a values are never emitted)
    //  - etc.
}
