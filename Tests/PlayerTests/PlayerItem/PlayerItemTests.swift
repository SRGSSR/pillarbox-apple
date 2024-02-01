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
        let item = PlayerItem.simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(title: "title")
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(item.asset.nowPlayingInfo()).notTo(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleItemWithoutConfiguration() {
        let item = PlayerItem.simple(url: Stream.onDemand.url, metadata: AssetMetadataMock(title: "title"))
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(item.asset.nowPlayingInfo()).notTo(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testSimpleItemWithoutMetadata() {
        let item = PlayerItem.simple(
            url: Stream.onDemand.url
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(item.asset.nowPlayingInfo()).to(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleAssetWithoutMetadataAndConfiguration() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.simple(url: Stream.onDemand.url)))
        expect(item.asset.nowPlayingInfo()).to(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomAsset() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(
            url: Stream.onDemand.url,
            delegate: delegate,
            metadata: AssetMetadataMock(title: "title")
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).notTo(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testCustomAssetWithoutConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate, metadata: AssetMetadataMock(title: "title"))
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).notTo(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomAssetWithoutMetadata() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(
            url: Stream.onDemand.url,
            delegate: delegate
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).to(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testCustomAssetWithoutMetadataAndConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).to(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedAsset() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(
            url: Stream.onDemand.url,
            delegate: delegate,
            metadata: AssetMetadataMock(title: "title")
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).notTo(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedAssetWithoutConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate, metadata: AssetMetadataMock(title: "title"))
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).notTo(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedAssetWithoutMetadata() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(
            url: Stream.onDemand.url,
            delegate: delegate
        ) { item in
            item.preferredForwardBufferDuration = 4
        }
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).to(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedAssetWithoutMetadataAndConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(id: item.id)
        expect(item.asset.resource).to(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.asset.nowPlayingInfo()).to(beEmpty())
        expect(item.asset.playerItem().preferredForwardBufferDuration).to(equal(0))
    }
}
