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
    private enum TestError: Error {
        case any
    }

    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    func testValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortStreamUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublisher(Player.ItemState.publisher(for: item), values: [.unknown, .readyToPlay, .ended]) {
            player.play()
        }
    }

    func testUnavailableStream() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableStreamUrl)
        let _ = AVPlayer(playerItem: item)
        try expectPublisher(Player.ItemState.publisher(for: item), values: [.unknown, .failed(error: TestError.any)])
    }

    func testCorruptStream() throws {
        let item = AVPlayerItem(url: TestStreams.corruptStreamUrl)
        let _ = AVPlayer(playerItem: item)
        try expectPublisher(Player.ItemState.publisher(for: item), values: [.unknown, .failed(error: TestError.any)])
    }

    func testResourceLoadingFailure() throws {
        let asset = AVURLAsset(url: TestStreams.customStreamUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: queue)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        try expectPublisher(Player.ItemState.publisher(for: item), values: [.unknown, .failed(error: TestError.any)]) {
            player.play()
        }
    }
}
