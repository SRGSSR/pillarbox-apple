//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import Player
import Streams

private struct AssetMetadataMock: AssetMetadata {}

final class CommandersActTrackerMetadataTests: CommandersActTestCase {
    func testWhenInitialized() {
        var player: Player?
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
                expect(labels.media_volume).notTo(beNil())
                expect(labels.media_title).to(equal("title"))
            }
        ) {
             player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                metadata: AssetMetadataMock(),
                trackerAdapters: [
                    CommandersActTracker.adapter { _ in
                        .test(streamType: .onDemand)
                    }
                ]
            ))
            player?.setDesiredPlaybackSpeed(0.5)
            player?.play()
        }
    }

    func testWhenDestroyed() {
        var player: Player? = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
                expect(labels.media_volume).notTo(beNil())
                expect(labels.media_title).to(equal("title"))
            }
        ) {
            player = nil
        }
    }

    func testMuted() {
        var player: Player?
        expectAtLeastHits(
            .play { labels in
                expect(labels.media_volume).to(equal(0))
            }
        ) {
             player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                metadata: AssetMetadataMock(),
                trackerAdapters: [
                    CommandersActTracker.adapter { _ in
                        .test(streamType: .onDemand)
                    }
                ]
            ))
            player?.isMuted = true
            player?.play()
        }
    }
}
