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

    func testEmptyState() {
        let player = Player()
        expect(player.state).to(beSimilarTo(.idle))
    }

    func testInitialStateWithItem() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        expect(player.state).to(beSimilarTo(.idle))
    }

    func testInitialPausedState() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        expect(player.state).toEventually(beSimilarTo(.paused), timeout: .seconds(2))
    }

    func testInitialPlayingState() {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        let player = Player(item: item)
        player.play()
        expect(player.state).toEventually(beSimilarTo(.playing), timeout: .seconds(2))
    }
}
