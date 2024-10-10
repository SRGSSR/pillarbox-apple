//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import PillarboxCircumspect
import PillarboxStreams
import XCTest

final class PlaybackTests: XCTestCase {
    private func playbackStatePublisher(for player: Player) -> AnyPublisher<PlaybackState, Never> {
        player.propertiesPublisher
            .slice(at: \.playbackState)
            .eraseToAnyPublisher()
    }

    func testHLS() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [.idle, .paused],
            from: playbackStatePublisher(for: player)
        )
    }

    func testMP3() {
        let item = PlayerItem.simple(url: Stream.mp3.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [.idle, .paused],
            from: playbackStatePublisher(for: player)
        )
    }

    func testUnknown() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [.idle],
            from: playbackStatePublisher(for: player),
            during: .seconds(1)
        )
    }
}
