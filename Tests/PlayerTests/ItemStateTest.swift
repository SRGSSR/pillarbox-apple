//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import XCTest

@MainActor
final class ItemStateTests: XCTestCase {
    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    func testValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.unknown, .readyToPlay, .ended], from: Player.statePublisher(for: item)) {
            player.play()
        }
    }

    func testUnavailableStream() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        _ = AVPlayer(playerItem: item)
        try expectPublished(values: [.unknown, .failed(error: TestError.any)], from: Player.statePublisher(for: item))
    }

    func testCorruptStream() throws {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemandUrl)
        _ = AVPlayer(playerItem: item)
        try expectPublished(values: [.unknown, .failed(error: TestError.any)], from: Player.statePublisher(for: item))
    }

    func testResourceLoadingFailure() throws {
        let asset = AVURLAsset(url: TestStreams.customUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: queue)
        let item = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.unknown, .failed(error: TestError.any)], from: Player.statePublisher(for: item)) {
            player.play()
        }
    }

    func testNonPlayingValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        _ = AVPlayer(playerItem: item)
        try expectPublished(values: [.unknown, .readyToPlay], from: Player.statePublisher(for: item))
    }
}
