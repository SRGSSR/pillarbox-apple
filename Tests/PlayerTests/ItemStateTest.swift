//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import XCTest

final class ItemStateTests: XCTestCase {
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    @MainActor
    func testValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublisher(Player.statePublisher(for: item), values: [.unknown, .readyToPlay, .ended]) {
            player.play()
        }
    }

    @MainActor
    func testUnavailableStream() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        _ = AVPlayer(playerItem: item)
        try expectPublisher(Player.statePublisher(for: item), values: [.unknown, .failed(error: TestError.any)])
    }

    @MainActor
    func testCorruptStream() throws {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemandUrl)
        _ = AVPlayer(playerItem: item)
        try expectPublisher(Player.statePublisher(for: item), values: [.unknown, .failed(error: TestError.any)])
    }

    @MainActor
    func testResourceLoadingFailure() throws {
        let asset = AVURLAsset(url: TestStreams.customUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: queue)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        try expectPublisher(Player.statePublisher(for: item), values: [.unknown, .failed(error: TestError.any)]) {
            player.play()
        }
    }

    @MainActor
    func testNonPlayingValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        _ = AVPlayer(playerItem: item)
        try expectPublisher(Player.statePublisher(for: item), values: [.unknown, .readyToPlay])
    }
}
