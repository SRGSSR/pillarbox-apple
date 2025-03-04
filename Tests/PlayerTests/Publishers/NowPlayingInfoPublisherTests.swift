//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import MediaPlayer
import PillarboxCircumspect
import PillarboxStreams

final class NowPlayingInfoPublisherTests: TestCase {
    private static func nowPlayingInfoPublisher(for player: Player) -> AnyPublisher<NowPlaying.Info, Never> {
        player.nowPlayingPublisher()
            .map(\.info)
            .removeDuplicates(by: ~~)
            .eraseToAnyPublisher()
    }

    func testInactive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:]],
            from: Self.nowPlayingInfoPublisher(for: player)
        )
    }

    func testToggleActive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:], ["title": "title"]],
            from: Self.nowPlayingInfoPublisher(for: player)
        ) {
            player.isActive = true
        }

        expectAtLeastSimilarPublishedNext(
            values: [[:]],
            from: Self.nowPlayingInfoPublisher(for: player)
        ) {
            player.isActive = false
        }
    }
}
