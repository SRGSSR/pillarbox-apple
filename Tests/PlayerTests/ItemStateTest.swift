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
    private var player: AVPlayer?

    private let resourceLoaderDelegate = FailingResourceLoaderDelegate()
    private let queue = DispatchQueue(label: "ch.srgssr.failing-resource-loader")

    private enum TestError: Error {
        case message1
        case message2
    }

    override func tearDown() {
        player = nil
    }

    func testValidStream() throws {
        let item = AVPlayerItem(url: URL(string: "http://localhost:8000/valid_stream/master.m3u8")!)
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
        ]))
    }

    func testUnavailableStream() throws {
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

    func testCorruptStream() throws {
        let item = AVPlayerItem(url: URL(string: "http://localhost:8000/corrupt_stream/master.m3u8")!)
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

    func testResourceLoadingFailure() throws {
        let asset = AVURLAsset(url: URL(string: "custom://arbitrary.server/some.m3u8")!)
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
            .failed
        ]))
    }

    func testFailedToPlayToEndTime() {
        // TODO: Cannot find a use case to test `AVPlayerItemFailedToPlayToEndTime` and no documentation is provided.
        //       When is this notification actually posted? Already tested: Stream with missing chunks.
        fail()
    }
}
