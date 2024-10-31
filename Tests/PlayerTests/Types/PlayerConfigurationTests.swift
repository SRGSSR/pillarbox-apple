//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class PlayerConfigurationTests: TestCase {
    func testPlayerConfigurationDefaultValues() {
        let configuration = PlayerConfiguration()
        let player = Player(configuration: configuration)
        expect(player.configuration.allowsExternalPlayback).to(beTrue())
        expect(player.configuration.usesExternalPlaybackWhileMirroring).to(beFalse())
        expect(player.configuration.preventsDisplaySleepDuringVideoPlayback).to(beTrue())
        expect(player.configuration.navigationMode).to(equal(.smart(interval: 3)))
        expect(player.configuration.backwardSkipInterval).to(equal(10))
        expect(player.configuration.forwardSkipInterval).to(equal(10))
        expect(player.configuration.preloadedItems).to(equal(2))
        expect(player.configuration.allowsConstrainedNetworkAccess).to(beTrue())
        expect(player.configuration.preferredPeakBitRate).to(equal(0))
        expect(player.configuration.preferredPeakBitRateForExpensiveNetworks).to(equal(0))
        expect(player.configuration.preferredMaximumResolution).to(equal(.zero))
        expect(player.configuration.preferredMaximumResolutionForExpensiveNetworks).to(equal(.zero))
    }

    func testPlayerConfigurationInit() {
        let configuration = PlayerConfiguration(
            allowsExternalPlayback: false,
            usesExternalPlaybackWhileMirroring: true,
            preventsDisplaySleepDuringVideoPlayback: false,
            navigationMode: .immediate,
            backwardSkipInterval: 42,
            forwardSkipInterval: 47,
            allowsConstrainedNetworkAccess: false,
            preferredPeakBitRate: 100,
            preferredPeakBitRateForExpensiveNetworks: 200,
            preferredMaximumResolution: .init(width: 100, height: 200),
            preferredMaximumResolutionForExpensiveNetworks: .init(width: 300, height: 400)
        )
        let player = Player(configuration: configuration)
        expect(player.configuration.allowsExternalPlayback).to(beFalse())
        expect(player.configuration.usesExternalPlaybackWhileMirroring).to(beTrue())
        expect(player.configuration.preventsDisplaySleepDuringVideoPlayback).to(beFalse())
        expect(player.configuration.navigationMode).to(equal(.immediate))
        expect(player.configuration.backwardSkipInterval).to(equal(42))
        expect(player.configuration.forwardSkipInterval).to(equal(47))
        expect(player.configuration.allowsConstrainedNetworkAccess).to(beFalse())
        expect(player.configuration.preferredPeakBitRate).to(equal(100))
        expect(player.configuration.preferredPeakBitRateForExpensiveNetworks).to(equal(200))
        expect(player.configuration.preferredMaximumResolution).to(equal(.init(width: 100, height: 200)))
        expect(player.configuration.preferredMaximumResolutionForExpensiveNetworks).to(equal(.init(width: 300, height: 400)))
    }
}
