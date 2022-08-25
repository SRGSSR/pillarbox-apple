//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

// TODO:
//  - Keep time range after playback end (in properties)
//  - Test with several items (also after playback end)
//  - Maybe make time range optional and if present guarantee always valid
//  - Same for time
//  - Better wait criteria before the time range / stream type can be checked?

final class TimeRangeTests: XCTestCase {
    func testOnDemandStream() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        _ = AVPlayer(playerItem: item)
        expect(item.status).toEventually(equal(.readyToPlay))
        expect(Time.timeRange(for: item)).to(equal(
            CMTimeRangeMake(start: .zero, duration: CMTime(value: 120, timescale: 1)),
            by: beClose(within: 0.5)
        ))
    }

    func testLiveStream() {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        _ = AVPlayer(playerItem: item)
        expect(item.status).toEventually(equal(.readyToPlay))
        expect(Time.timeRange(for: item)).to(equal(
            .zero,
            by: beClose(within: 0.5)
        ))
    }

    func testWithoutItem() {
        expect(Time.timeRange(for: nil)).to(equal(.invalid))
    }

    func testNonReadyStream() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        _ = AVPlayer(playerItem: item)
        expect(Time.timeRange(for: item)).to(equal(
            .invalid,
            by: beClose(within: 0.5)
        ))
    }
}

final class CloseTests: XCTestCase {
    func testCloseWithFiniteTimes() {
        expect(Time.close(within: 0)(CMTime.zero, .zero)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.zero, .zero)).to(beTrue())

        expect(Time.close(within: 0.5)(CMTime(value: 2, timescale: 1), CMTime(value: 2, timescale: 1))).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime(value: 2, timescale: 1), CMTime(value: 200, timescale: 100))).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.zero, CMTime(value: 1, timescale: 2))).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.zero, CMTime(value: 2, timescale: 1))).to(beFalse())

        expect(Time.close(within: 0)(CMTime.zero, CMTime(value: 1, timescale: 10000))).to(beFalse())
    }

    func testCloseWithPositiveInfiniteValues() {
        expect(Time.close(within: 0)(CMTime.positiveInfinity, .positiveInfinity)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.positiveInfinity, .positiveInfinity)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .negativeInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .indefinite)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .invalid)).to(beFalse())
    }

    func testCloseWithMinusInfiniteValues() {
        expect(Time.close(within: 0)(CMTime.negativeInfinity, .negativeInfinity)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.negativeInfinity, .negativeInfinity)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .positiveInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .indefinite)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .invalid)).to(beFalse())
    }

    func testCloseWithIndefiniteValues() {
        expect(Time.close(within: 0)(CMTime.indefinite, .indefinite)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.indefinite, .indefinite)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.indefinite, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.indefinite, .positiveInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.indefinite, .negativeInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.indefinite, .invalid)).to(beFalse())
    }

    func testCloseWithInvalidValues() {
        expect(Time.close(within: 0)(CMTime.invalid, .invalid)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.invalid, .invalid)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.invalid, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.invalid, .positiveInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.invalid, .negativeInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.invalid, .indefinite)).to(beFalse())
    }
}
