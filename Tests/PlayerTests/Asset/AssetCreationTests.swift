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
        let asset = Asset.simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(title: "title")
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(asset.nowPlayingInfo()).notTo(beEmpty())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleAssetWithoutConfiguration() {
        let asset = Asset.simple(url: Stream.onDemand.url, metadata: AssetMetadataMock(title: "title"))
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(asset.nowPlayingInfo()).notTo(beEmpty())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testSimpleAssetWithoutMetadata() {
        let asset = Asset.simple(
            url: Stream.onDemand.url
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(asset.nowPlayingInfo()).to(beNil())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleAssetWithoutMetadataAndConfiguration() {
        let asset = Asset.simple(url: Stream.onDemand.url)
        expect(asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(asset.nowPlayingInfo()).to(beNil())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomAsset() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(
            url: Stream.onDemand.url,
            delegate: delegate,
            metadata: AssetMetadataMock(title: "title")
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).notTo(beEmpty())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
        expect(asset.playerItem().externalMetadata).toNot(beEmpty())
    }

    func testCustomAssetWithoutConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(url: Stream.onDemand.url, delegate: delegate, metadata: AssetMetadataMock(title: "title"))
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).notTo(beEmpty())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomAssetWithoutMetadata() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(
            url: Stream.onDemand.url,
            delegate: delegate
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).to(beNil())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testCustomAssetWithoutMetadataAndConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let asset = Asset.custom(url: Stream.onDemand.url, delegate: delegate)
        expect(asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).to(beNil())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedAsset() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(
            url: Stream.onDemand.url,
            delegate: delegate,
            metadata: AssetMetadataMock(title: "title")
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).notTo(beEmpty())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedAssetWithoutConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(url: Stream.onDemand.url, delegate: delegate, metadata: AssetMetadataMock(title: "title"))
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).notTo(beEmpty())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedAssetWithoutMetadata() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(
            url: Stream.onDemand.url,
            delegate: delegate
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).to(beNil())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedAssetWithoutMetadataAndConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let asset = Asset.encrypted(url: Stream.onDemand.url, delegate: delegate)
        expect(asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(asset.nowPlayingInfo()).to(beNil())
        expect(asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }
}
