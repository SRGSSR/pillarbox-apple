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
        let item = PlayerItem.simple(url: Stream.onDemand.url, configuration: .init(preferredForwardBufferDuration: 4))
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        expect(item.content.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleItemWithoutConfiguration() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        expect(item.content.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomItem() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate, configuration: .init(preferredForwardBufferDuration: 4))
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.content.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testCustomItemWithoutConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.content.playerItem().preferredForwardBufferDuration).to(equal(0))
    }

    func testEncryptedItem() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate, configuration: .init(preferredForwardBufferDuration: 4))
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.content.playerItem().preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedItemWithoutConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.content.playerItem().preferredForwardBufferDuration).to(equal(0))
    }
}
