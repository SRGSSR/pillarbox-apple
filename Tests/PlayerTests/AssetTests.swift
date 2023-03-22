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

final class AssetTests: TestCase {
    func testSimpleEquality() {
        expect(Asset.simple(url: Stream.dvr.url)).to(equal(.simple(url: Stream.dvr.url)))
        expect(Asset.simple(url: Stream.live.url)).notTo(equal(.simple(url: Stream.dvr.url)))
        expect(Asset.simple(url: Stream.live.url)).notTo(equal(.custom(url: Stream.live.url, delegate: LoadingResourceLoaderDelegate())))
    }

    func testCustomEquality() {
        let delegate1 = LoadingResourceLoaderDelegate()
        expect(Asset.custom(url: Stream.dvr.url, delegate: delegate1)).to(equal(Asset.custom(url: Stream.dvr.url, delegate: delegate1)))
        let delegate2 = LoadingResourceLoaderDelegate()
        expect(Asset.custom(url: Stream.dvr.url, delegate: delegate1)).notTo(equal(Asset.custom(url: Stream.dvr.url, delegate: delegate2)))
        expect(Asset.custom(url: Stream.live.url, delegate: delegate1)).notTo(equal(Asset.custom(url: Stream.dvr.url, delegate: delegate1)))
    }

    func testEncryptedEquality() {
        let delegate1 = DummyContentKeySessionDelegate()
        expect(Asset.encrypted(url: Stream.dvr.url, delegate: delegate1)).to(equal(Asset.encrypted(url: Stream.dvr.url, delegate: delegate1)))
        let delegate2 = DummyContentKeySessionDelegate()
        expect(Asset.encrypted(url: Stream.dvr.url, delegate: delegate1)).notTo(equal(Asset.encrypted(url: Stream.dvr.url, delegate: delegate2)))
        expect(Asset.encrypted(url: Stream.live.url, delegate: delegate1)).notTo(equal(Asset.encrypted(url: Stream.dvr.url, delegate: delegate1)))
    }

    func testNativePlayerItem() {
        let item = Asset.simple(url: Stream.onDemand.url).playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testLoadingPlayerItem() {
        let item = Asset<Void>.loading.playerItem()
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false],
            from: item.publisher(for: \.isPlaybackLikelyToKeepUp)
        )
    }

    func testFailingPlayerItem() {
        let item = Asset<Void>.failed(error: StructError()).playerItem()
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
