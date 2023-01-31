//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Nimble
import XCTest

final class QueuePlayerSeekTests: XCTestCase {
    private static func notificationPublisher(for names: Set<Notification.Name>, object: AnyObject?, center: NotificationCenter = .default) -> AnyPublisher<Notification, Never> {
        Publishers.MergeMany(names.map { name in
            center.weakPublisher(for: name, object: object)
        })
        .eraseToAnyPublisher()
    }

    func testSeekWithEmptyPlayer() {
        let player = QueuePlayer(items: [])
        expect {
            player.seek(to: CMTime(value: 1, timescale: 1), toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beFalse())
            }
        }.to(postNotifications(equalDiff([])))
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
            Notification(name: .willSeek, object: player),
            Notification(name: .seek, object: player, userInfo: [
                SeekKey.time: time
            ]),
            Notification(name: .didSeek, object: player)
        ])))
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
            Notification(name: .willSeek, object: player),
            Notification(name: .seek, object: player, userInfo: [
                SeekKey.time: time1
            ]),
            Notification(name: .didSeek, object: player),

            Notification(name: .willSeek, object: player),
            Notification(name: .seek, object: player, userInfo: [
                SeekKey.time: time2
            ]),
            Notification(name: .didSeek, object: player)
        ])))
    }

    func testMultipleSeeksWhileReady() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.play()
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expectAtLeastEqualPublished(
            values: [
                Notification(name: .willSeek, object: player),
                Notification(name: .seek, object: player, userInfo: [
                    SeekKey.time: time1
                ]),
                Notification(name: .seek, object: player, userInfo: [
                    SeekKey.time: time2
                ]),
                Notification(name: .didSeek, object: player)
            ],
            from: Self.notificationPublisher(for: [.willSeek, .seek, .didSeek], object: player)
        ) {
            player.seek(to: time1, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beFalse())
            }
            player.seek(to: time2, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity) { finished in
                expect(finished).to(beTrue())
            }
        }
    }
}

// Question: Should we have tests waiting for the player to be ready before seeking?
