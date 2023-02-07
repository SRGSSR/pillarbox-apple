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

final class QueuePlayerSmoothSeekTests: XCTestCase {
    func testSeekWithEmptyPlayer() {
        let player = QueuePlayer()
        expect {
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beFalse())
            }
        }.to(postNotifications(equalDiff([]), from: QueuePlayer.notificationCenter))
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testSeekWithCompletion() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testSeekWithCompletionAndTolerances() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testMultipleSeeks() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .didSeek, object: player),

            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testMultipleSeeksWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testSmoothSeekAfterSeekWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }
}
