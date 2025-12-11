//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import OrderedCollections
import PillarboxCircumspect
import PillarboxStreams
import XCTest

private class QueuePlayerMock: QueuePlayer {
    var seeks: Int = 0

    override func enqueue(seek: Seek, completion: @escaping () -> Void) {
        self.seeks += 1
        super.enqueue(seek: seek, completion: completion)
    }
}

final class QueuePlayerSeekTests: TestCase {
    func testNotificationsForSeekWithInvalidTime() throws {
        guard nimbleThrowAssertionsAvailable() else {
            throw XCTSkip("Skipped due to missing throw assertion test support.")
        }
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect { player.seek(to: .invalid) }.to(throwAssertion())
    }

    func testNotificationsForSeekWithEmptyPlayer() {
        let player = QueuePlayer()
        expect {
            player.seek(to: CMTime(value: 1, timescale: 1)) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expect {
            player.seek(to: time) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    func testNotificationsForMultipleSeeks() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expect {
            player.seek(to: time1) { finished in
                expect(finished).to(beTrue())
            }
            player.seek(to: time2) { finished in
                expect(finished).to(beTrue())
            }
        }.to(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time1]),
            Notification(name: .didSeek, object: player),

            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    @MainActor
    func testNotificationsForMultipleSeeksWithinTimeRange() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)

        await expect {
            player.seek(to: time1) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: time2) { finished in
                expect(finished).to(beTrue())
            }
            return ()
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    @MainActor
    func testNotificationsForSeekAfterSmoothSeekWithinTimeRange() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        await expect {
            player.seek(to: time1, smooth: true) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: time2) { finished in
                expect(finished).to(beTrue())
            }
            return ()
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time2]),
            Notification(name: .didSeek, object: player)
        ]), from: QueuePlayer.notificationCenter))
    }

    @MainActor
    func testCompletionsForMultipleSeeks() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

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

        player.seek(to: time1, completionHandler: completion(index: 1))
        player.seek(to: time2, completionHandler: completion(index: 2))
        player.seek(to: time3, completionHandler: completion(index: 3))

        await expect(results).toEventually(equalDiff([
            1: false,
            2: false,
            3: true
        ]))
    }

    @MainActor
    func testCompletionsForMultipleSmoothSeeksEndingWithSeek() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

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
        player.seek(to: time3, smooth: false, completionHandler: completion(index: 3))

        await expect(results).toEventually(equalDiff([
            1: false,
            2: false,
            3: true
        ]))
    }

    // Checks that time is not jumping back when seeking forward several times in a row (no tolerance before is allowed
    // in this test as otherwise the player is allowed to pick a position before the desired position),
    @MainActor
    func testMultipleSeekMonotonicity() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.play()
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

        let values = collectOutput(from: player.smoothCurrentTimePublisher(interval: CMTime(value: 1, timescale: 10), queue: .main), during: .seconds(3)) {
            player.seek(to: CMTime(value: 8, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                player.seek(to: CMTime(value: 10, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                    player.seek(to: CMTime(value: 12, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                        player.seek(to: CMTime(value: 100, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                            player.seek(to: CMTime(value: 100, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                        }
                    }
                }
            }
        }
        expect(values.sorted()).to(equal(values))
    }

    @MainActor
    func testNotificationCompletionOrder() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

        let time = CMTime(value: 1, timescale: 1)
        let notificationName = Notification.Name("SeekCompleted")
        await expect {
            player.seek(to: time) { _ in
                QueuePlayer.notificationCenter.post(name: notificationName, object: self)
            }
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time]),
            Notification(name: .didSeek, object: player),
            Notification(name: notificationName, object: self)
        ]), from: QueuePlayer.notificationCenter))
    }

    @MainActor
    func testNotificationCompletionOrderWithMultipleSeeks() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        let notificationName1 = Notification.Name("SeekCompleted1")
        let notificationName2 = Notification.Name("SeekCompleted2")
        await expect {
            player.seek(to: time1) { _ in
                QueuePlayer.notificationCenter.post(name: notificationName1, object: self)
            }
            player.seek(to: time2) { _ in
                QueuePlayer.notificationCenter.post(name: notificationName2, object: self)
            }
            return ()
        }.toEventually(postNotifications(equalDiff([
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time1]),
            Notification(name: .willSeek, object: player, userInfo: [SeekNotificationKey.time: time2]),
            Notification(name: notificationName1, object: self),
            Notification(name: .didSeek, object: player),
            Notification(name: notificationName2, object: self)
        ]), from: QueuePlayer.notificationCenter))
    }

    @MainActor
    func testEnqueue() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayerMock(playerItem: item)
        await expect(player.timeRange).toEventuallyNot(equal(.invalid))
        await waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1))
            player.seek(to: CMTime(value: 2, timescale: 1))
            player.seek(to: CMTime(value: 3, timescale: 1))
            player.seek(to: CMTime(value: 4, timescale: 1))
            player.seek(to: CMTime(value: 5, timescale: 1)) { _ in
                done()
            }
        }
        expect(player.seeks).to(equal(5))
    }

    @MainActor
    func testEnqueueSmooth() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayerMock(playerItem: item)
        await expect(player.timeRange).toEventuallyNot(equal(.invalid))
        await waitUntil { done in
            player.seek(to: CMTime(value: 1, timescale: 1), smooth: true) { _ in }
            player.seek(to: CMTime(value: 2, timescale: 1), smooth: true) { _ in }
            player.seek(to: CMTime(value: 3, timescale: 1), smooth: true) { _ in }
            player.seek(to: CMTime(value: 4, timescale: 1), smooth: true) { _ in }
            player.seek(to: CMTime(value: 5, timescale: 1), smooth: true) { _ in
                done()
            }
        }
        expect(player.seeks).to(equal(2))
    }

    @MainActor
    func testTargetSeekTimeWithMultipleSeeks() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        await expect(player.timeRange).toEventuallyNot(equal(.invalid))

        let time1 = CMTime(value: 1, timescale: 1)
        await player.seek(to: time1)
        expect(player.targetSeekTime).to(equal(time1))

        let time2 = CMTime(value: 2, timescale: 1)
        await player.seek(to: time2)
        expect(player.targetSeekTime).to(equal(time2))
    }
}
