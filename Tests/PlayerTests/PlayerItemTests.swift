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

final class PlayerItemsTests: XCTestCase {
    private struct SomeError: Error {}

    func testNativePlayerItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp),
            during: 2
        )
    }

    func testLoadingPlayerItem() {
        let item = LoadingPlayerItem()
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp),
            during: 2
        )
    }

    func testFailingPlayerItem() {
        let item = FailingPlayerItem(error: SomeError())
        _ = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [.unknown, .failed(error: TestError.any)],
            from: item.itemStatePublisher(),
            during: 2
        )
    }

    func testGenericItem() {
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        let publisher = Just(playerItem)
        let item = PlayerItem(publisher: publisher)
        expectAtLeastSimilarPublished(
            values: [
                playerItem
            ],
            from: item.$playerItem
        )
    }

    func testUrlItem() {
        let item = PlayerItem(url: Stream.onDemand.url)
        expectAtLeastSimilarPublished(
            values: [
                AVPlayerItem(url: Stream.onDemand.url)
            ],
            from: item.$playerItem
        )
    }

    func testAssetItem() {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let item = PlayerItem(asset: asset)
        expectAtLeastSimilarPublished(
            values: [
                AVPlayerItem(url: Stream.onDemand.url)
            ],
            from: item.$playerItem
        )
    }

    func testRawItem() {
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        let item = PlayerItem(playerItem)
        expectAtLeastSimilarPublished(
            values: [
                playerItem
            ],
            from: item.$playerItem
        )
    }

    func testCustomItemSuccessAsync() {
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        let publisher = Just(playerItem)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
        let item = PlayerItem(publisher: publisher)
        expectAtLeastSimilarPublished(
            values: [
                LoadingPlayerItem(),
                playerItem
            ],
            from: item.$playerItem
        )
    }

    func testCustomItemFailureAsync() {
        let publisher = Fail<AVPlayerItem, Error>(error: TestError.any)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
        let item = PlayerItem(publisher: publisher)
        expectAtLeastSimilarPublished(
            values: [
                LoadingPlayerItem(),
                FailingPlayerItem(error: TestError.any)
            ],
            from: item.$playerItem
        )
    }
}
