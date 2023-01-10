//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class PlayerConfigurationTests: XCTestCase {
    func testPlayerConfigurationDefaultValues() {
        let configuration = PlayerConfiguration()
        let player = Player(configuration: configuration)
        expect(player.configuration.allowsExternalPlayback).to(beTrue())
        expect(player.configuration.usesExternalPlaybackWhileMirroring).to(beFalse())
    }

    func testPlayerConfigurationInit() {
        let configuration = PlayerConfiguration(
            allowsExternalPlayback: false,
            usesExternalPlaybackWhileMirroring: true
        )
        let player = Player(configuration: configuration)
        expect(player.configuration.allowsExternalPlayback).to(beFalse())
        expect(player.configuration.usesExternalPlaybackWhileMirroring).to(beTrue())
    }
}
