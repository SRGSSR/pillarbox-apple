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

final class ItemStateTests: XCTestCase {
    var player: AVPlayer? = nil

    private enum TestError: Error {
        case message1
        case message2
    }

    override func tearDown() {
        player = nil
    }

    func testUnknown() throws {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let state = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .first()
        )
        expect(state).to(equal(.unknown))
    }

    func testReadyToPlay() throws {
        let item = AVPlayerItem(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!)
        player = AVPlayer(playerItem: item)
        let states = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .collectFirst(2)
        )
        expect(states).to(equal([
            .unknown,
            .readyToPlay
        ]))
    }

    func testEnded() {
        // TODO: Requires a proper test sample
        fail()
    }

    func testFailure() throws {
        let item = AVPlayerItem(url: URL(string: "http://httpbin.org/status/404")!)
        player = AVPlayer(playerItem: item)
        let states = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .collectFirst(2)
        )
        expect(states).to(equal([
            .unknown,
            .failed
        ]))
    }
}
