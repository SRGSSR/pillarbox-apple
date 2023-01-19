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
    func testSimpleEquality() {
        expect(Asset(type: .simple(url: Stream.dvr.url))).to(equal(Asset(type: .simple(url: Stream.dvr.url))))
        expect(Asset(type: .simple(url: Stream.live.url))).notTo(equal(Asset(type: .simple(url: Stream.dvr.url))))
        expect(Asset(type: .simple(url: Stream.live.url))).notTo(equal(Asset(type: .custom(url: Stream.live.url, delegate: LoadingResourceLoaderDelegate()))))
    }

    func testCustomEquality() {
        let delegate1 = LoadingResourceLoaderDelegate()
        expect(Asset(type: .custom(url: Stream.dvr.url, delegate: delegate1))).to(equal(Asset(type: .custom(url: Stream.dvr.url, delegate: delegate1))))
        let delegate2 = LoadingResourceLoaderDelegate()
        expect(Asset(type: .custom(url: Stream.dvr.url, delegate: delegate1))).notTo(equal(Asset(type: .custom(url: Stream.dvr.url, delegate: delegate2))))
        expect(Asset(type: .custom(url: Stream.live.url, delegate: delegate1))).notTo(equal(Asset(type: .custom(url: Stream.dvr.url, delegate: delegate1))))
    }

    func testEncryptedEquality() {
        let delegate1 = DummyContentKeySessionDelegate()
        expect(Asset(type: .encrypted(url: Stream.dvr.url, delegate: delegate1))).to(equal(Asset(type: .encrypted(url: Stream.dvr.url, delegate: delegate1))))
        let delegate2 = DummyContentKeySessionDelegate()
        expect(Asset(type: .encrypted(url: Stream.dvr.url, delegate: delegate1))).notTo(equal(Asset(type: .encrypted(url: Stream.dvr.url, delegate: delegate2))))
        expect(Asset(type: .encrypted(url: Stream.live.url, delegate: delegate1))).notTo(equal(Asset(type: .encrypted(url: Stream.dvr.url, delegate: delegate1))))
    }

    func testNativePlayerItem() {
        let item = Asset(type: .simple(url: Stream.onDemand.url)).playerItem()
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
