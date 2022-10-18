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
    struct SomeError: Error {}

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

    func testCustomItemSuccess() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let publisher = Just(item)
            .setFailureType(to: Error.self)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
        let customItem = PlayerItem(publisher: publisher)
        expectAtLeastPublished(
            values: [
                LoadingPlayerItem(),
                item
            ],
            from: customItem.$item
        ) { lhsItem, rhsItem in
            guard lhsItem !== rhsItem else { return true }
            return type(of: lhsItem) == type(of: rhsItem)
        }
    }

    func testCustomItemFailure() {
        let publisher = Fail<AVPlayerItem, Error>(error: TestError.any)
            .delay(for: 0.5, scheduler: DispatchQueue.main)
        let customItem = PlayerItem(publisher: publisher)
        expectAtLeastPublished(
            values: [
                LoadingPlayerItem(),
                FailingPlayerItem(error: TestError.any)
            ],
            from: customItem.$item
        ) { lhsItem, rhsItem in
            guard lhsItem !== rhsItem else { return true }
            return type(of: lhsItem) == type(of: rhsItem)
        }
    }
}
