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

final class QueuePlayerInvalidSeekTests: XCTestCase {
    func testNotificationsForSeekWithInvalidTime() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect {
            player.seek(to: .invalid) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForInvalidSeekAfterValidSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime.invalid
        expect {
            player.seek(to: time1) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForInvalidSeekAlwaysFinishes() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime.invalid
        let time3 = CMTime(value: 3, timescale: 1)

        expect {
            player.seek(to: time1, isSmooth: true) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: time2) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time3) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time3]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }

    func testNotificationsForInvalidSeekAfterValidSeekWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime.invalid
        expect {
            player.seek(to: time1) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2) { finished in
                expect(finished).to(beTrue())
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekKey.time: time1]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter), timeout: .seconds(5))
    }
}
