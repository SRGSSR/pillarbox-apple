//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

@MainActor
final class PlayerTests: XCTestCase {
    func testEmpty() {
        let player = DequePlayer()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(beEmpty())
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(beEmpty())
    }

    func testPlayerDeallocation() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }
}
