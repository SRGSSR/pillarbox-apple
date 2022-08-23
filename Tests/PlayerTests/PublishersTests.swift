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

final class PublishersTests: XCTestCase {
    func testPeriodicTimeDuringPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        player.play()
        try expectPublisher(
            player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 2)),
            values: [
                CMTimeMake(value: 0, timescale: 2),
                CMTimeMake(value: 1, timescale: 2),
                CMTimeMake(value: 2, timescale: 2),
                CMTimeMake(value: 3, timescale: 2),
                CMTimeMake(value: 4, timescale: 2),
                CMTimeMake(value: 5, timescale: 2)
            ],
            toBe: close(within: 0.5)
        )
    }

    func testPeriodicTimeDuringSeek() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }

        Task {
            await player.seek(
                to: CMTime(value: 3, timescale: 2),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )
        }
        try expectPublisher(
            player.periodicTimePublisher(forInterval: CMTimeMake(value: 1, timescale: 2)),
            values: [
                CMTimeMake(value: 3, timescale: 2),
                CMTimeMake(value: 4, timescale: 2),
                CMTimeMake(value: 5, timescale: 2),
                CMTimeMake(value: 6, timescale: 2)
            ],
            toBe: close(within: 0.5)
        )
    }

    func testWeakNotificationWithoutObject() throws {
        let notificationCenter = NotificationCenter.default
        try awaitPublisher(notificationCenter.weakPublisher(for: .testNotification).first()) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }

    func testWeakNotificationWithObject() throws {
        let object = TestObject()
        let notificationCenter = NotificationCenter.default
        try awaitPublisher(notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWeakNotificationWithNSObject() throws {
        let object = TestNSObject()
        let notificationCenter = NotificationCenter.default
        try awaitPublisher(notificationCenter.weakPublisher(for: .testNotification, object: object).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWeakNotificationWithValueType() throws {
        let object = TestStruct()
        let notificationCenter = NotificationCenter.default
        try awaitPublisher(notificationCenter.weakPublisher(for: .testNotification).first()) {
            notificationCenter.post(name: .testNotification, object: object)
        }
    }

    func testWeakNotificationAfterObjectRelease() throws {
        let notificationCenter = NotificationCenter.default
        var object: TestObject? = TestObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        autoreleasepool {
            object = nil
        }
        expect(weakObject).to(beNil())

        // We were interested in notifications from `object` only. After its release we should not receive other
        // notifications from any other source anymore.
        try notAwaitPublisher(publisher) {
            notificationCenter.post(name: .testNotification, object: nil)
        }
    }

    // TODO:
    //  - Test without playing (no events; requires a way to check that values are never emitted)
    //  - Test with pause
    //  - Similar individual tests for other publishers in Publishers.swift (Player package)
    //  - etc.
}
