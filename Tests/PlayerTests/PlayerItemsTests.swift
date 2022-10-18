//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class PlayerItemsTests: XCTestCase {
    struct SomeError: Error {}

    func testPlayerItem() {
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
}
