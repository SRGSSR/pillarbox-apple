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

    private var player: AVPlayer?

    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    override func tearDown() {
        super.tearDown()
        player = nil
    }

    func testValidStream() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        player = AVPlayer(playerItem: item)
        player!.play()
        Task {
            let duration = try await item.asset.load(.duration)
            await player!.seek(
                to: CMTimeSubtract(duration, CMTime(value: 1, timescale: 10)),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )
        }
        let states = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .collectFirst(3)
        )
        expect(states).to(equal([
            .unknown,
            .readyToPlay,
            .ended
        ], by: areSimilar))
    }

    func testUnavailableStream() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableStreamUrl)
        player = AVPlayer(playerItem: item)
        let states = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .collectFirst(2)
        )
        expect(states).to(equal([
            .unknown,
            .failed(error: TestError.any)
        ], by: areSimilar))
    }

    func testCorruptStream() throws {
        let item = AVPlayerItem(url: TestStreams.corruptStreamUrl)
        player = AVPlayer(playerItem: item)
        let states = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .collectFirst(2)
        )
        expect(states).to(equal([
            .unknown,
            .failed(error: TestError.any)
        ], by: areSimilar))
    }

    func testResourceLoadingFailure() throws {
        let asset = AVURLAsset(url: TestStreams.customStreamUrl)
        asset.resourceLoader.setDelegate(resourceLoaderDelegate, queue: queue)
        let item = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: item)
        player?.play()
        let states = try awaitPublisher(
            Player.ItemState.publisher(for: item)
                .collectFirst(2)
        )
        expect(states).to(equal([
            .unknown,
            .failed(error: TestError.any)
        ], by: areSimilar))
    }
}
