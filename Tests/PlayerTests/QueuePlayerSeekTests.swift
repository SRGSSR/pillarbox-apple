//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import OrderedCollections
import XCTest

final class QueuePlayerSeekTests: XCTestCase {
    func testSeekWithEmptyPlayer() {
        let player = QueuePlayer()
        expect {
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([]), from: QueuePlayer.notificationCenter))
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testSeekWithInvalidTime() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect {
            player.seek(to: .invalid, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([]), from: QueuePlayer.notificationCenter))
    }

    func testSeekWithCompletion() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time) { finished in
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
            player.seek(to: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
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
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .didSeek, object: player),

            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testInvalidSeekAfterValidSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime.invalid
        expect {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
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
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testInvalidSeekAfterValidSeekWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime.invalid
        expect {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testSeekAfterSmoothSeekWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity, isSmooth: true) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testSeekCancellation() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        let time3 = CMTime(value: 3, timescale: 1)

        var results = OrderedDictionary<Int, Bool>()

        func completion(index: Int) -> ((Bool) -> Void) {
            { finished in
                expect(results[index]).to(beNil())
                results[index] = finished
            }
        }

        player.seek(
            to: time1,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            completionHandler: completion(index: 1)
        )
        player.seek(
            to: time2,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            completionHandler: completion(index: 2)
        )
        player.seek(
            to: time3,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            completionHandler: completion(index: 3)
        )

        expect(results).toEventually(equalDiff([
            1: false,
            2: false,
            3: true
        ]))
    }

    func testMultipleSmoothSeeksThenSeekThenSmoothSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        let time3 = CMTime(value: 3, timescale: 1)
        let time4 = CMTime(value: 4, timescale: 1)
        let time5 = CMTime(value: 5, timescale: 1)

        var results = OrderedDictionary<Int, Bool>()

        func completion(index: Int) -> ((Bool) -> Void) {
            { finished in
                expect(results[index]).to(beNil())
                results[index] = finished
            }
        }

        player.seek(
            to: time1,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            isSmooth: true,
            completionHandler: completion(index: 1)
        )
        player.seek(
            to: time2,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            isSmooth: true,
            completionHandler: completion(index: 2)
        )
        player.seek(
            to: time3,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            isSmooth: true,
            completionHandler: completion(index: 3)
        )
        player.seek(
            to: time4,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            isSmooth: false,
            completionHandler: completion(index: 4)
        )
        player.seek(
            to: time5,
            toleranceBefore: .positiveInfinity,
            toleranceAfter: .positiveInfinity,
            isSmooth: true,
            completionHandler: completion(index: 5)
        )
        
        expect(results).toEventually(equalDiff([
            1: false,
            2: false,
            3: false,
            4: true,
            5: true
        ]))
    }
}
