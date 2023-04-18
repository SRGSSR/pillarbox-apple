//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Nimble
import Streams
import XCTest

final class AssetPlayerItemTests: TestCase {
    func testNativePlayerItem() {
        let item = Asset.simple(url: Stream.onDemand.url).playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testLoadingPlayerItem() {
        let item = EmptyAsset.loading.playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testFailingPlayerItem() {
        let item = EmptyAsset.failed(error: StructError()).playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [
                .unknown,
                .failed(error: NSError(
                    domain: "PlayerTests.StructError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Struct error description"
                    ]
                ))
            ],
            from: item.itemStatePublisher()
        )
    }
}
