//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import CoreMedia
import Nimble
import PillarboxStreams

private struct AnyError: Error {}

final class PlaybackConfigurationTests: TestCase {
    func testDefaultValues() {
        let configuration = PlaybackConfiguration()
        expect(configuration.position.time).to(equal(.zero))
        expect(configuration.automaticallyPreservesTimeOffsetFromLive).to(beFalse())
        expect(configuration.preferredForwardBufferDuration).to(equal(0))
    }

    func testCustomValues() {
        let time = CMTime(value: 7, timescale: 1)
        let configuration = PlaybackConfiguration(
            position: at(time),
            automaticallyPreservesTimeOffsetFromLive: true,
            preferredForwardBufferDuration: 11
        )
        expect(configuration.position.time).to(equal(time))
        expect(configuration.automaticallyPreservesTimeOffsetFromLive).to(beTrue())
        expect(configuration.preferredForwardBufferDuration).to(equal(11))
    }

    func testApplyToPlayerItem() {
        let time = CMTime(value: 7, timescale: 1)
        let configuration = PlaybackConfiguration(
            position: at(time),
            automaticallyPreservesTimeOffsetFromLive: true,
            preferredForwardBufferDuration: 11
        )
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        configuration.apply(to: playerItem, metadata: .init(), resumeState: nil)
        expect(playerItem.currentTime()).to(equal(time))
        expect(playerItem.automaticallyPreservesTimeOffsetFromLive).to(beTrue())
        expect(playerItem.preferredForwardBufferDuration).to(equal(11))
    }

    func testApplyToPlayerItemWithPositionInBlockedTimeRange() {
        let blockedTimeRangeEnd = CMTime(value: 17, timescale: 1)
        let configuration = PlaybackConfiguration(position: at(.init(value: 7, timescale: 1)))
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        configuration.apply(
            to: playerItem,
            metadata: .init(timeRanges: [
                .init(kind: .blocked, start: .init(value: 2, timescale: 1), end: blockedTimeRangeEnd)
            ]),
            resumeState: nil
        )
        expect(playerItem.currentTime()).to(equal(blockedTimeRangeEnd))
    }

    func testApplyToPlayerItemWithMatchingResumeState() {
        let configuration = PlaybackConfiguration(position: at(.init(value: 7, timescale: 1)))
        let id = UUID()
        let playerItem = AVPlayerItem(url: Stream.onDemand.url).withId(id)
        let resumePosition = CMTime(value: 14, timescale: 1)
        configuration.apply(to: playerItem, metadata: .init(), resumeState: .init(position: at(resumePosition), id: id))
        expect(playerItem.currentTime()).to(equal(resumePosition))
    }

    func testApplyToPlayerItemWithNonMatchingResumeState() {
        let startTime = CMTime(value: 7, timescale: 1)
        let configuration = PlaybackConfiguration(position: at(startTime))
        let playerItem = AVPlayerItem(url: Stream.onDemand.url).withId(UUID())
        configuration.apply(to: playerItem, metadata: .init(), resumeState: .init(position: at(.init(value: 14, timescale: 1)), id: UUID()))
        expect(playerItem.currentTime()).to(equal(startTime))
    }

    func testDoesNotApplyToLoadingPlayerItemWithMatchingResumeState() {
        let startTime = CMTime(value: 7, timescale: 1)
        let configuration = PlaybackConfiguration(position: at(startTime))
        let id = UUID()
        let playerItem = Resource.loading().playerItem(configuration: .default).withId(id)
        configuration.apply(to: playerItem, metadata: .init(), resumeState: .init(position: at(.init(value: 14, timescale: 1)), id: id))
        expect(playerItem.currentTime()).to(equal(startTime))
    }

    func testDoesNotApplyToFailedPlayerItemWithMatchingResumeState() {
        let startTime = CMTime(value: 7, timescale: 1)
        let configuration = PlaybackConfiguration(position: at(startTime))
        let id = UUID()
        let playerItem = Resource.failing(error: AnyError()).playerItem(configuration: .default).withId(id)
        configuration.apply(to: playerItem, metadata: .init(), resumeState: .init(position: at(.init(value: 14, timescale: 1)), id: id))
        expect(playerItem.currentTime()).to(equal(startTime))
    }

    func testApplyToPlayerItemWithMatchingResumeStateInBlockedTimeRange() {
        let blockedTimeRangeEnd = CMTime(value: 17, timescale: 1)
        let configuration = PlaybackConfiguration(position: at(.init(value: 7, timescale: 1)))
        let id = UUID()
        let playerItem = AVPlayerItem(url: Stream.onDemand.url).withId(UUID())
        configuration.apply(
            to: playerItem,
            metadata: .init(timeRanges: [
                .init(kind: .blocked, start: .init(value: 2, timescale: 1), end: blockedTimeRangeEnd)
            ]),
            resumeState: .init(position: at(.init(value: 14, timescale: 1)), id: id)
        )
        expect(playerItem.currentTime()).to(equal(blockedTimeRangeEnd))
    }
}
