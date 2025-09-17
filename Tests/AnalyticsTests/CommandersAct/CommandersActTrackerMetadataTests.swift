//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble
import PillarboxPlayer
import PillarboxStreams

final class CommandersActTrackerMetadataTests: CommandersActTestCase {
    func testWhenInitialized() {
        var player: Player?
        expectAtLeastHits(
            play { labels in
                expect(labels.consent_services).to(equal("service1,service2,service3"))
                expect(labels.media_airplay_on).to(beFalse())
                expect(labels.media_audio_track).to(equal("UND"))
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).to(equal(PackageInfo.version))
                expect(labels.media_title).to(equal("name"))
                expect(labels.media_volume).notTo(beNil())
            }
        ) {
             player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    CommandersActTracker.adapter { _ in .test }
                ]
            ))
            player?.setDesiredPlaybackSpeed(0.5)
            player?.play()
        }
    }

    func testWhenDestroyed() {
        var player: Player? = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            stop { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).to(equal(PackageInfo.version))
                expect(labels.media_volume).notTo(beNil())
                expect(labels.media_title).to(equal("name"))
                expect(labels.media_audio_track).to(equal("UND"))
            }
        ) {
            player = nil
        }
    }

    func testMuted() {
        var player: Player?
        expectAtLeastHits(
            play { labels in
                expect(labels.media_volume).to(equal(0))
            }
        ) {
             player = Player(item: .simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [
                    CommandersActTracker.adapter { _ in .test }
                ]
            ))
            player?.isMuted = true
            player?.play()
        }
    }

    func testAudioTrack() {
        let player = Player(item: .simple(
            url: Stream.onDemandWithOptions.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.setMediaSelectionPreference(.on(languages: "fr"), for: .audible)
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            pause { labels in
                expect(labels.media_audio_track).to(equal("FR"))
            }
        ) {
            player.pause()
        }
    }

    func testSubtitlesOff() {
        let player = Player(item: .simple(
            url: Stream.onDemandWithOptions.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))
        player.select(mediaOption: .off, for: .legible)
        expect(player.currentMediaOption(for: .legible)).toEventually(equal(.off))

        expectAtLeastHits(
            pause { labels in
                expect(labels.media_subtitles_on).to(beFalse())
            }
        ) {
            player.pause()
        }
    }

    func testSubtitlesOn() {
        let player = Player(item: .simple(
            url: Stream.onDemandWithOptions.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.setMediaSelectionPreference(.on(languages: "fr"), for: .legible)
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            pause { labels in
                expect(labels.media_subtitles_on).to(beTrue())
                expect(labels.media_subtitle_selection).to(equal("FR"))
            }
        ) {
            player.pause()
        }
    }
}
