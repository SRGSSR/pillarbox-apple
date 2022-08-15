//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import AVFoundation
import Nimble
import XCTest

final class StateTests: XCTestCase {
    func testEquality() {
        expect(Player.State.idle).to(equal(.idle))
    }

    func testInequality() {
        expect(Player.State.idle).notTo(equal(.playing))
    }

    func testEmptyState() {
        let player = Player()
        expect(player.state).to(equal(.idle))
    }

    func testInitialStateWithItem() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        expect(player.state).to(equal(.idle))
    }

    func testInitialPausedState() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        expect(player.state).toEventually(equal(.paused), timeout: .seconds(2))
    }

    func testInitialPlayingState() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        player.play()
        expect(player.state).toEventually(equal(.playing), timeout: .seconds(2))
    }
}
