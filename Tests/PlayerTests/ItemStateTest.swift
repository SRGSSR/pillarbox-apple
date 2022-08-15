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

    func testSimpleEquality() {
        expect(Player.ItemState.unknown).to(equal(.unknown))
        expect(Player.ItemState.readyToPlay).to(equal(.readyToPlay))
        expect(Player.ItemState.ended).to(equal(.ended))
    }

    func testFailureEquality() {
        expect(Player.ItemState.failed(error: TestError.message1)).to(equal(.failed(error: TestError.message1)))
    }

    func testSimpleInequality() {
        expect(Player.ItemState.unknown).notTo(equal(.readyToPlay))
        expect(Player.ItemState.readyToPlay).notTo(equal(.failed(error: TestError.message1)))
    }

    func testFailureInequality() {
        expect(Player.ItemState.failed(error: TestError.message1)).notTo(equal(.failed(error: TestError.message2)))
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
        fail()
    }

    func testFailure() {
        fail()
    }
}
