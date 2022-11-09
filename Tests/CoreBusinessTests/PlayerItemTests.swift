//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Circumspect
import Nimble
import Player
import XCTest

@MainActor
final class PlayerItemTests: XCTestCase {
    func testURNPlaybackHLS() {
        let item = PlayerItem(urn: "urn:rts:video:6820736")
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [
                .idle,
                .paused
            ],
            from: player.$playbackState
        )
    }

    func testURNPlaybackMP3() {
        let item = PlayerItem(urn: "urn:rsi:audio:8833144")
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [
                .idle,
                .paused
            ],
            from: player.$playbackState
        )
    }

    func testURNPlaybackUnknown() {
        let item = PlayerItem(urn: "urn:srf:video:unknown")
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [
                .idle,
                .failed(error: NSError(
                    domain: "CoreBusiness.DataError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Not found"
                    ]
                ))
            ],
            from: player.$playbackState
        )
    }

    func testURNPlaybackNotAvailableAnymore() {
        let item = PlayerItem(urn: "urn:rts:video:13382911")
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [
                .idle,
                .failed(error: NSError(
                    domain: "CoreBusiness.DataError",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "This content is not available anymore."
                    ]
                ))
            ],
            from: player.$playbackState
        )
    }
}
