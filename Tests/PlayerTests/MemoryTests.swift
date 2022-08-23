//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class MemoryTests: XCTestCase {
    func testPlayerRelease() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testWeakNotificationObjectRelease() throws {
        let notificationCenter = NotificationCenter.default
        var object: TestObject? = TestObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        _ = try autoreleasepool {
            try awaitPublisher(publisher) {
                notificationCenter.post(name: .testNotification, object: object)
            }
            object = nil
        }
        expect(weakObject).to(beNil())
    }

    func testWeakNotificationNSObjectRelease() throws {
        let notificationCenter = NotificationCenter.default
        var object: TestNSObject? = TestNSObject()
        let publisher = notificationCenter.weakPublisher(for: .testNotification, object: object).first()

        weak var weakObject = object
        _ = try autoreleasepool {
            try awaitPublisher(publisher) {
                notificationCenter.post(name: .testNotification, object: object)
            }
            object = nil
        }
        expect(weakObject).to(beNil())
    }
}
