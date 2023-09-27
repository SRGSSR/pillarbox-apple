//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import CoreMedia
import Nimble
import Player
import Streams

private struct AssetMetadataMock: AssetMetadata {}

final class CommandersActTrackerPositionTests: CommandersActTestCase {
    func testLivePlayback() {
        let player = Player(item: .simple(
            url: Stream.live.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .live)
                }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player.pause()
        }
    }

    func testDvrPlayback() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player.pause()
        }
    }

    func testSeekDuringDvrPlayback() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            .seek { labels in
                expect(labels.media_position).to(equal(0))
            },
            .play { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    func testDestroyDuringLivePlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.live.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .live)
                }
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player = nil
        }
    }

    func testDestroyDuringDvrPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .dvr)
                }
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player = nil
        }
    }
}
