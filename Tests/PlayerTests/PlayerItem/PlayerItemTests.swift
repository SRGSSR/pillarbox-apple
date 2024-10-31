//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class PlayerItemTests: TestCase {
    private static let limits = PlayerLimits(
        preferredPeakBitRate: 100,
        preferredPeakBitRateForExpensiveNetworks: 200,
        preferredMaximumResolution: .init(width: 100, height: 200),
        preferredMaximumResolutionForExpensiveNetworks: .init(width: 300, height: 400)
    )

    func testSimpleItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        let playerItem = item.content.playerItem(configuration: .default, limits: .none)
        expect(playerItem.preferredForwardBufferDuration).to(equal(0))
        expect(playerItem.preferredPeakBitRate).to(equal(0))
        expect(playerItem.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
        expect(playerItem.preferredMaximumResolution).to(equal(.zero))
        expect(playerItem.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
    }

    func testSimpleItemWithConfiguration() {
        let item = PlayerItem.simple(url: Stream.onDemand.url, configuration: .init(preferredForwardBufferDuration: 4))
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        expect(item.content.playerItem(configuration: .default, limits: .none).preferredForwardBufferDuration).to(equal(4))
    }

    func testSimpleItemWithLimits() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.simple(url: Stream.onDemand.url)))
        let playerItem = item.content.playerItem(configuration: .default, limits: Self.limits)
        expect(playerItem.preferredPeakBitRate).to(equal(100))
        expect(playerItem.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
        expect(playerItem.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
        expect(playerItem.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
    }

    func testCustomItem() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        let playerItem = item.content.playerItem(configuration: .default, limits: .none)
        expect(playerItem.preferredForwardBufferDuration).to(equal(0))
        expect(playerItem.preferredPeakBitRate).to(equal(0))
        expect(playerItem.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
        expect(playerItem.preferredMaximumResolution).to(equal(.zero))
        expect(playerItem.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
    }

    func testCustomItemWithConfiguration() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(
            url: Stream.onDemand.url,
            delegate: delegate,
            configuration: .init(preferredForwardBufferDuration: 4)
        )
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.content.playerItem(
            configuration: .default,
            limits: .none
        ).preferredForwardBufferDuration).to(equal(4))
    }

    func testCustomItemWithLimits() {
        let delegate = ResourceLoaderDelegateMock()
        let item = PlayerItem.custom(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.custom(url: Stream.onDemand.url, delegate: delegate)))
        let playerItem = item.content.playerItem(configuration: .default, limits: Self.limits)
        expect(playerItem.preferredPeakBitRate).to(equal(100))
        expect(playerItem.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
        expect(playerItem.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
        expect(playerItem.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
    }

    func testEncryptedItem() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        let playerItem = item.content.playerItem(configuration: .default, limits: .none)
        expect(playerItem.preferredForwardBufferDuration).to(equal(0))
        expect(playerItem.preferredPeakBitRate).to(equal(0))
        expect(playerItem.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
        expect(playerItem.preferredMaximumResolution).to(equal(.zero))
        expect(playerItem.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
    }

    func testEncryptedItemWithConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(
            url: Stream.onDemand.url,
            delegate: delegate,
            configuration: .init(preferredForwardBufferDuration: 4)
        )
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        expect(item.content.playerItem(
            configuration: .default,
            limits: .none
        ).preferredForwardBufferDuration).to(equal(4))
    }

    func testEncryptedItemWithNonStandardPlayerConfiguration() {
        let delegate = ContentKeySessionDelegateMock()
        let item = PlayerItem.encrypted(url: Stream.onDemand.url, delegate: delegate)
        PlayerItem.load(for: item.id)
        expect(item.content.resource).toEventually(equal(.encrypted(url: Stream.onDemand.url, delegate: delegate)))
        let playerItem = item.content.playerItem(configuration: .default, limits: Self.limits)
        expect(playerItem.preferredPeakBitRate).to(equal(100))
        expect(playerItem.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
        expect(playerItem.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
        expect(playerItem.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
    }
}
