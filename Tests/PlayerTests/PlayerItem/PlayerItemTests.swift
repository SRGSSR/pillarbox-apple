//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class PlayerItemTests: TestCase {
    func testSimpleItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(for: item.id)
        expect(item.asset.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleItemWithoutConfiguration() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        PlayerItem.load(for: item.id)
        expect(item.asset.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomAsset() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(for: item.id)
        expect(item.asset.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testCustomAssetWithoutConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.asset.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedAsset() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(for: item.id)
        expect(item.asset.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedAssetWithoutConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.asset.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }
}
