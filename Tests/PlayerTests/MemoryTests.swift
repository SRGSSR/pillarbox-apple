//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

private extension Notification.Name {
    static let testNotification = Notification.Name("TestNotification")
}

final class MemoryTests: XCTestCase {
    func testPlayerRelease() {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testWeakPublisherObjectRelease() throws {
        let notificationCenter = NotificationCenter.default
        try awaitPublisher(
            notificationCenter.weakPublisher(for: .testNotification).first()
        ) {
            notificationCenter.post(Notification(name: .testNotification))
        }
    }
}
