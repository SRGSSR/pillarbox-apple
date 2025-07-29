//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble

final class PlayerConfigurationTests: TestCase {
    func testDefaultValues() {
        let configuration = PlayerConfiguration()
        expect(configuration.allowsExternalPlayback).to(beTrue())
        expect(configuration.usesExternalPlaybackWhileMirroring).to(beFalse())
        expect(configuration.preventsDisplaySleepDuringVideoPlayback).to(beTrue())
        expect(configuration.navigationMode).to(equal(.smart(interval: 3)))
        expect(configuration.backwardSkipInterval).to(equal(10))
        expect(configuration.forwardSkipInterval).to(equal(10))
        expect(configuration.preloadedItems).to(equal(2))
        expect(configuration.allowsConstrainedNetworkAccess).to(beTrue())
    }

    func testCustomValues() {
        let configuration = PlayerConfiguration(
            allowsExternalPlayback: false,
            usesExternalPlaybackWhileMirroring: true,
            preventsDisplaySleepDuringVideoPlayback: false,
            navigationMode: .immediate,
            backwardSkipInterval: 42,
            forwardSkipInterval: 47,
            allowsConstrainedNetworkAccess: false
        )
        expect(configuration.allowsExternalPlayback).to(beFalse())
        expect(configuration.usesExternalPlaybackWhileMirroring).to(beTrue())
        expect(configuration.preventsDisplaySleepDuringVideoPlayback).to(beFalse())
        expect(configuration.navigationMode).to(equal(.immediate))
        expect(configuration.backwardSkipInterval).to(equal(42))
        expect(configuration.forwardSkipInterval).to(equal(47))
        expect(configuration.allowsConstrainedNetworkAccess).to(beFalse())
    }
}
