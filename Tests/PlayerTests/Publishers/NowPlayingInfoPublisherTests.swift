//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import MediaPlayer
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class NowPlayingInfoPublisherTests: TestCase {
    private static func nowPlayingInfoPublisher(for player: Player) -> AnyPublisher<NowPlaying.Info, Never> {
        player.nowPlayingPublisher()
            .map(\.info)
            .eraseToAnyPublisher()
    }

    func testInactive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectSimilarPublished(
            values: [[:]],
            from: Self.nowPlayingInfoPublisher(for: player),
            during: .milliseconds(100)
        )
    }

    func testToggleActive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:], [MPNowPlayingInfoPropertyIsLiveStream: false]],
            from: Self.nowPlayingInfoPublisher(for: player)
        ) {
            player.isActive = true
        }

        expectSimilarPublishedNext(
            values: [[:]],
            from: Self.nowPlayingInfoPublisher(for: player),
            during: .milliseconds(100)
        ) {
            player.isActive = false
        }
    }
}
