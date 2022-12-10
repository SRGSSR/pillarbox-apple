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
import XCTest

final class AssetTests: XCTestCase {
    func testNativePlayerItem() {
        let item = Asset.simple(url: Stream.onDemand.url).playerItem()
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp),
            during: 2
        )
    }

    func testLoadingPlayerItem() {
        let item = Asset.loading.playerItem()
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp),
            during: 2
        )
    }

    func testFailingPlayerItem() {
        let item = Asset.failed(error: StructError()).playerItem()
        _ = AVPlayer(playerItem: item)
        expectEqualPublished(
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
            from: item.itemStatePublisher(),
            during: 2
        )
    }
}
