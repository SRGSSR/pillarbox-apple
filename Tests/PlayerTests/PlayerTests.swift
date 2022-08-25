//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

@MainActor
final class PlaybackStateTests: XCTestCase {
    func testPlaybackStartPaused() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .paused], from: player.$playbackState)
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing], from: player.$playbackState) {
            player.play()
        }
    }

    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing], from: player.$playbackState) {
            player.play()
        }
        try expectPublishedNext(values: [.paused], from: player.$playbackState) {
            player.pause()
        }
        try expectPublishedNext(values: [.playing], from: player.$playbackState) {
            player.play()
        }
    }

    func testTogglePlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing], from: player.$playbackState) {
            player.play()
        }
        try expectPublishedNext(values: [.paused, .playing], from: player.$playbackState) {
            player.togglePlayPause()
            player.togglePlayPause()
        }
    }

    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing, .ended], from: player.$playbackState) {
            player.play()
        }
    }

    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .failed(error: TestError.any)], from: player.$playbackState)
    }

    func testPlaybackWithItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(items: [item1, item2])
        try expectPublishedNext(values: [.idle, .playing, .ended, .playing, .ended], from: player.$playbackState) {
            player.play()
        }
    }

    func testWithoutPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .paused], from: player.$playbackState, during: 3)
    }

    func testWithoutItems() throws {
        let player = Player()
        try expectPublished(values: [.idle], from: player.$playbackState, during: 3)
    }
}

@MainActor
final class PlayerDeallocationTests: XCTestCase {
    func testPlayerDeallocation() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }
}

@MainActor
final class PlayerItemTests: XCTestCase {
    func testEmptyItems() {
        let player = Player()
        expect(player.items).to(equal([]))
    }

    func testItems() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        expect(player.items).to(equal([item1, item2]))
    }

    func testSingleItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(item: item)
        expect(player.items).to(equal([item]))
    }

    func testInsertion() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])

        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item3, after: item1)
        expect(player.items).to(equal([item1, item3, item2]))
    }

    func testInsertionAfterNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])

        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item3, after: nil)
        expect(player.items).to(equal([item1, item2, item3]))
    }

    func testAppend() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])

        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.append(item3)
        expect(player.items).to(equal([item1, item2, item3]))
    }

    func testRemoval() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(item: item)
        player.remove(item)
        expect(player.items).to(equal([]))
    }

    func testUnknownItemRemoval() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(item: item)

        let unknownItem = AVPlayerItem(url: URL(string: "https://www.server.com/unknown.m3u8")!)
        player.remove(unknownItem)
        expect(player.items).to(equal([item]))
    }

    func testRemovalWhenEmpty() {
        let player = Player()
        let unknownItem = AVPlayerItem(url: URL(string: "https://www.server.com/unknown.m3u8")!)
        player.remove(unknownItem)
        expect(player.items).to(equal([]))
    }

    func testRemoveAll() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        player.removeAllItems()
        expect(player.items).to(equal([]))
    }
}
