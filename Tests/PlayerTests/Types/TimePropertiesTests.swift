//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble

final class TimePropertiesTests: TestCase {
    func testWithoutTimeRange() {
        expect(TimeProperties.timeRange(from: [])).to(beNil())
    }

    func testTimeRange() {
        expect(TimeProperties.timeRange(from: [NSValue(timeRange: .oneSecond)])).to(equal(.oneSecond))
    }

    func testTimeRanges() {
        expect(TimeProperties.timeRange(from: [
            NSValue(timeRange: .init(start: .init(value: 1, timescale: 1), duration: .init(value: 3, timescale: 1))),
            NSValue(timeRange: .init(start: .init(value: 10, timescale: 1), duration: .init(value: 5, timescale: 1))),
        ])).to(equal(
            .init(start: .init(value: 1, timescale: 1), duration: .init(value: 14, timescale: 1))
        ))
    }

    func testInvalidTimeRange() {
        expect(TimeProperties.timeRange(from: [NSValue(timeRange: .invalid)])).to(equal(.invalid))
    }

    func testSeekableTimeRangeFallback() {
        expect(
            TimeProperties.timeRange(
                loadedTimeRanges: [NSValue(timeRange: .oneSecond)],
                seekableTimeRanges: []
            )
        )
        .to(equal(.zero))
    }

    func testBufferEmptyLoadedTimeRanges() {
        expect(
            TimeProperties(
                loadedTimeRanges: [],
                seekableTimeRanges: [NSValue(timeRange: .oneSecond)],
                isPlaybackLikelyToKeepUp: true
            ).buffer
        )
        .to(equal(0))
    }

    func testBuffer() {
        expect(
            TimeProperties(
                loadedTimeRanges: [NSValue(timeRange: .oneSecond)],
                seekableTimeRanges: [NSValue(timeRange: .oneSecond)],
                isPlaybackLikelyToKeepUp: true
            ).buffer
        )
        .to(equal(1))
    }

    func testBufferClamped() {
        expect(
            TimeProperties(
                loadedTimeRanges: [NSValue(timeRange: .twoSeconds)],
                seekableTimeRanges: [NSValue(timeRange: .oneSecond)],
                isPlaybackLikelyToKeepUp: true
            ).buffer
        )
        .to(equal(1))
    }

    func testSmoothedSeekableTimeRangeEndWithoutUpdateTime() {
        let properties = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .twoSeconds)],
            isPlaybackLikelyToKeepUp: true
        )
        expect(properties.smoothedSeekableTimeRangeEnd(chunkDuration: .init(value: 1, timescale: 1))).to(equal(.init(value: 2, timescale: 1)))
    }

    func testSmoothedSeekableTimeRangeEndWithInvalidChunkDuration() {
        let properties = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .twoSeconds)],
            isPlaybackLikelyToKeepUp: true
        ).updated(from: .empty)
        expect(properties.smoothedSeekableTimeRangeEnd(chunkDuration: .invalid)).to(equal(.init(value: 2, timescale: 1)))
    }

    func testSmoothedSeekableTimeRangeEndAfterUpdate() {
        let properties = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .twoSeconds)],
            isPlaybackLikelyToKeepUp: true
        ).updated(from: .empty)
        let end = properties.smoothedSeekableTimeRangeEnd(chunkDuration: .init(value: 1, timescale: 1))
        expect(end.seconds).to(beCloseTo(1, within: 0.1))
    }

    func testSmoothedSeekableTimeRangeEndIsClamped() {
        let properties = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .twoSeconds)],
            isPlaybackLikelyToKeepUp: true,
            seekableTimeRangeEndUpdateTime: CMClockGetTime(CMClockGetHostTimeClock()) - CMTime(value: 10, timescale: 1)
        )
        expect(properties.smoothedSeekableTimeRangeEnd(chunkDuration: .init(value: 1, timescale: 1))).to(equal(.init(value: 2, timescale: 1)))
    }

    func testUpdateTimePreservedWhenEndIsUnchanged() {
        let updateTime = CMTime(value: 1, timescale: 1)
        let previous = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .oneSecond)],
            isPlaybackLikelyToKeepUp: false,
            seekableTimeRangeEndUpdateTime: updateTime
        )
        let properties = TimeProperties(
            loadedTimeRanges: [NSValue(timeRange: .oneSecond)],
            seekableTimeRanges: [NSValue(timeRange: .oneSecond)],
            isPlaybackLikelyToKeepUp: true
        ).updated(from: previous)
        expect(properties.seekableTimeRangeEndUpdateTime).to(equal(updateTime))
    }

    func testUpdateTimeRefreshedWhenEndChanges() {
        let updateTime = CMTime(value: 1, timescale: 1)
        let previous = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .oneSecond)],
            isPlaybackLikelyToKeepUp: true,
            seekableTimeRangeEndUpdateTime: updateTime
        )
        let properties = TimeProperties(
            loadedTimeRanges: [],
            seekableTimeRanges: [NSValue(timeRange: .twoSeconds)],
            isPlaybackLikelyToKeepUp: true
        ).updated(from: previous)
        expect(properties.seekableTimeRangeEndUpdateTime).notTo(equal(updateTime))
    }
}

private extension CMTimeRange {
    static let oneSecond = Self(start: .zero, duration: .init(value: 1, timescale: 1))
    static let twoSeconds = Self(start: .zero, duration: .init(value: 2, timescale: 1))
}
