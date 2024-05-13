//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import MediaPlayer
import PillarboxCircumspect
import PillarboxStreams

final class NowPlayingInfoPublisherTests: TestCase {
    func testInactive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoPublisher(),
            during: .milliseconds(100)
        )
    }

    func testToggleActive() {
        let player = Player(item: .mock(url: Stream.onDemand.url, loadedAfter: 0, withMetadata: AssetMetadataMock(title: "title")))
        expectAtLeastSimilarPublished(
            values: [[:], [MPNowPlayingInfoPropertyIsLiveStream: false]],
            from: player.nowPlayingInfoPublisher()
        ) {
            player.isActive = true
        }

        expectSimilarPublishedNext(
            values: [[:]],
            from: player.nowPlayingInfoPublisher(),
            during: .milliseconds(100)
        ) {
            player.isActive = false
        }
    }
}
