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
    private enum TestError: Error {
        case message1
        case message2
    }

    func testSimpleEquality() {
        expect(Player.State.idle).to(equal(.idle))
        expect(Player.State.playing).to(equal(.playing))
        expect(Player.State.paused).to(equal(.paused))
        expect(Player.State.ended).to(equal(.ended))
    }

    func testFailureEquality() {
        expect(Player.State.failed(error: TestError.message1)).to(equal(.failed(error: TestError.message1)))
    }

    func testSimpleInequality() {
        expect(Player.State.idle).notTo(equal(.playing))
        expect(Player.State.playing).notTo(equal(.failed(error: TestError.message1)))
    }

    func testFailureInequality() {
        expect(Player.State.failed(error: TestError.message1)).notTo(equal(.failed(error: TestError.message2)))
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
