//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class PlayerLimitsTests: TestCase {
    private static let limits = PlayerLimits(
        preferredPeakBitRate: 100,
        preferredPeakBitRateForExpensiveNetworks: 200,
        preferredMaximumResolution: .init(width: 100, height: 200),
        preferredMaximumResolutionForExpensiveNetworks: .init(width: 300, height: 400)
    )

    func testDefaultValues() {
        let limits = PlayerLimits()
        expect(limits.preferredPeakBitRate).to(equal(0))
        expect(limits.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
        expect(limits.preferredMaximumResolution).to(equal(.zero))
        expect(limits.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
    }

    func testCustomValues() {
        let limits = PlayerLimits(
            preferredPeakBitRate: 100,
            preferredPeakBitRateForExpensiveNetworks: 200,
            preferredMaximumResolution: .init(width: 100, height: 200),
            preferredMaximumResolutionForExpensiveNetworks: .init(width: 300, height: 400)
        )
        expect(limits.preferredPeakBitRate).to(equal(100))
        expect(limits.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
        expect(limits.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
        expect(limits.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
    }

    func testAppliedDefaultValues() {
        let player = Player(items: [
            .simple(url: Stream.onDemand.url),
            .simple(url: Stream.mediumOnDemand.url)
        ])
        player.queuePlayer.items().forEach { item in
            expect(item.preferredPeakBitRate).to(equal(0))
            expect(item.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
            expect(item.preferredMaximumResolution).to(equal(.zero))
            expect(item.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
        }
    }

    func testAppliedInitialValues() {
        let player = Player(items: [
            .simple(url: Stream.onDemand.url),
            .simple(url: Stream.mediumOnDemand.url)
        ])
        player.limits = Self.limits
        player.queuePlayer.items().forEach { item in
            expect(item.preferredPeakBitRate).to(equal(100))
            expect(item.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
            expect(item.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
            expect(item.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
        }
    }

    @MainActor
    func testLoadedItem() async {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0.1))
        player.limits = Self.limits
        await expect(player.playbackState).toEventually(equal(.paused))
        player.queuePlayer.items().forEach { item in
            expect(item.preferredPeakBitRate).to(equal(100))
            expect(item.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
            expect(item.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
            expect(item.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
        }
    }
}
