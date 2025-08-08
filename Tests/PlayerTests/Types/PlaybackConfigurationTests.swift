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
        configuration.apply(to: playerItem, with: .init(), resumePosition: nil)
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
            with: .init(timeRanges: [
                .init(kind: .blocked, start: .init(value: 2, timescale: 1), end: blockedTimeRangeEnd)
            ]),
            resumePosition: nil
        )
        expect(playerItem.currentTime()).to(equal(blockedTimeRangeEnd))
    }

    func testApplyToPlayerItemWithResumePosition() {
        let configuration = PlaybackConfiguration(position: at(.init(value: 7, timescale: 1)))
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        let resumePosition = CMTime(value: 14, timescale: 1)
        configuration.apply(to: playerItem, with: .init(), resumePosition: at(resumePosition))
        expect(playerItem.currentTime()).to(equal(resumePosition))
    }

    func testApplyToPlayerItemWithResumePositionInBlockedTimeRange() {
        let blockedTimeRangeEnd = CMTime(value: 17, timescale: 1)
        let configuration = PlaybackConfiguration(position: at(.init(value: 7, timescale: 1)))
        let playerItem = AVPlayerItem(url: Stream.onDemand.url)
        configuration.apply(
            to: playerItem,
            with: .init(timeRanges: [
                .init(kind: .blocked, start: .init(value: 2, timescale: 1), end: blockedTimeRangeEnd)
            ]),
            resumePosition: at(.init(value: 14, timescale: 1))
        )
        expect(playerItem.currentTime()).to(equal(blockedTimeRangeEnd))
    }
}
