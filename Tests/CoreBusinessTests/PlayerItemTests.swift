//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCoreBusiness
@testable import PillarboxPlayer

import Combine
import Nimble
import PillarboxCircumspect
import XCTest

final class PlayerItemTests: XCTestCase {
    private func playbackStatePublisher(for player: Player) -> AnyPublisher<PlaybackState, Never> {
        player.propertiesPublisher
            .slice(at: \.playbackState)
            .eraseToAnyPublisher()
    }

    func testUrnPlaybackHLS() {
        let item = PlayerItem.urn("urn:rts:video:6820736")
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [.idle, .paused],
            from: playbackStatePublisher(for: player)
        )
    }

    func testUrnPlaybackMP3() {
        let item = PlayerItem.urn("urn:rsi:audio:1861947")
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [.idle, .paused],
            from: playbackStatePublisher(for: player)
        )
    }

    func testUrnPlaybackUnknown() {
        let item = PlayerItem.urn("urn:srf:video:unknown")
        let player = Player(item: item)
        expectEqualPublished(
            values: [.idle],
            from: playbackStatePublisher(for: player),
            during: .seconds(1)
        )
    }

    func testUrnPlaybackNotAvailableAnymore() {
        let item = PlayerItem.urn("urn:rts:video:13382911")
        let player = Player(item: item)
        expectEqualPublished(
            values: [.idle],
            from: playbackStatePublisher(for: player),
            during: .seconds(1)
        )
    }
}
