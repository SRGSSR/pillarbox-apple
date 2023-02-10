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

final class QueuePlayerSmoothSeekTests: XCTestCase {
    func testNotificationsForSeekWithEmptyPlayer() {
        let player = QueuePlayer()
        expect {
            player.seek(to: CMTime(value: 1, timescale: 1), smooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time, smooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForMultipleSeeks() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1, smooth: true) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, smooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .didSeek, object: player),

            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForMultipleSeeksWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1, smooth: true) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, smooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testNotificationsForSmoothSeekAfterSeekWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2, smooth: true) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testCompletionsForMultipleSeeks() {
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

        player.seek(to: time1, smooth: true, completionHandler: completion(index: 1))
        player.seek(to: time2, smooth: true, completionHandler: completion(index: 2))
        player.seek(to: time3, smooth: true, completionHandler: completion(index: 3))

        expect(results).toEventually(equalDiff([
            1: true,
            2: true,
            3: true
        ]))
    }

    func testCompletionsForMultipleSeeksEndingWithSmoothSeek() {
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

        player.seek(to: time1, smooth: false, completionHandler: completion(index: 1))
        player.seek(to: time2, smooth: false, completionHandler: completion(index: 2))
        player.seek(to: time3, smooth: true, completionHandler: completion(index: 3))

        expect(results).toEventually(equalDiff([
            1: false,
            2: true,
            3: true
        ]))
    }
}
