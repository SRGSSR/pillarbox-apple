//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble

final class PlayerConfigurationTests: TestCase {
    func testPlayerConfigurationDefaultValues() {
        let configuration = PlayerConfiguration()
        let player = Player(configuration: configuration)
        expect(player.configuration.allowsExternalPlayback).to(beTrue())
        expect(player.configuration.usesExternalPlaybackWhileMirroring).to(beFalse())
        expect(player.configuration.preventsDisplaySleepDuringVideoPlayback).to(beTrue())
        expect(player.configuration.audiovisualBackgroundPlaybackPolicy).to(equal(.automatic))
        expect(player.configuration.isSmartNavigationEnabled).to(beTrue())
        expect(player.configuration.backwardSkipInterval).to(equal(10))
        expect(player.configuration.forwardSkipInterval).to(equal(10))
    }

    func testPlayerConfigurationInit() {
        let configuration = PlayerConfiguration(
            allowsExternalPlayback: false,
            usesExternalPlaybackWhileMirroring: true,
            preventsDisplaySleepDuringVideoPlayback: false,
            audiovisualBackgroundPlaybackPolicy: .pauses,
            smartNavigationEnabled: false,
            backwardSkipInterval: 42,
            forwardSkipInterval: 47
        )
        let player = Player(configuration: configuration)
        expect(player.configuration.allowsExternalPlayback).to(beFalse())
        expect(player.configuration.usesExternalPlaybackWhileMirroring).to(beTrue())
        expect(player.configuration.preventsDisplaySleepDuringVideoPlayback).to(beFalse())
        expect(player.configuration.audiovisualBackgroundPlaybackPolicy).to(equal(.pauses))
        expect(player.configuration.isSmartNavigationEnabled).to(beFalse())
        expect(player.configuration.backwardSkipInterval).to(equal(42))
        expect(player.configuration.forwardSkipInterval).to(equal(47))
    }

    func testApplyPlayerConfigurationAfterInit() {
        let configuration = PlayerConfiguration(
            allowsExternalPlayback: false,
            smartNavigationEnabled: false
        )

        let player = Player()

        expect(player.configuration.allowsExternalPlayback).to(beFalse())
        expect(player.configuration.isSmartNavigationEnabled).to(beFalse())
    }
}
