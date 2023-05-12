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
        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
                expect(labels.media_volume).notTo(beNil())
                expect(labels.media_playback_rate).to(equal(1))
                expect(labels.media_bandwidth).to(equal(0))
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

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
                expect(labels.media_volume).notTo(beNil())
                expect(labels.media_playback_rate).to(equal(1))
                expect(labels.media_bandwidth).to(equal(0))
                expect(labels.media_title).to(equal("title"))
            }
        ) {
            player = nil
        }
    }

    func testMuted() {
        var player: Player?
        expectAtLeastEvents(
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
