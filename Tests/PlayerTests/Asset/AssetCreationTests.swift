//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class AssetCreationTests: TestCase {
    func testSimpleAsset() {
        let asset = Asset.simple(url: Stream.onDemand.url) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleAssetWithoutConfiguration() {
        let asset = Asset.simple(url: Stream.onDemand.url)
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomAsset() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(url: Stream.onDemand.url, delegate: delegate) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
        expect(asset.playerItem().externalMetadata).notTo(beEmpty())
    }

    func testCustomAssetWithoutConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(url: Stream.onDemand.url, delegate: delegate)
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedAsset() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(url: Stream.onDemand.url, delegate: delegate) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedAssetWithoutConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(url: Stream.onDemand.url, delegate: delegate)
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }
}
