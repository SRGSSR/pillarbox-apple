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
    func testEmpty() {
        let player = Player()
        expectAtLeastSimilarPublished(
            values: [[:]],
            from: player.nowPlayingInfoPublisher()
        )
    }

    func testActive() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(title: "title"),
            metadataAdapter: CommonMetadata.adapter { metadata in
                .init(title: metadata.title)
            }
        ))
        expectAtLeastSimilarPublished(
            values: [[:], [MPMediaItemPropertyTitle: "title"]],
            from: player.nowPlayingInfoPublisher()
        ) {
            player.isActive = true
        }

        expectAtLeastSimilarPublished(
            values: [[MPMediaItemPropertyTitle: "title"], [:]],
            from: player.nowPlayingInfoPublisher()
        ) {
            player.isActive = false
        }
    }
}
