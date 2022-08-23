//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class TimeTests: XCTestCase {
    func testEmptyTimeRange() throws {
        // TODO: Implement expectation which waits for a definite number of values then
        //       wait for other ones and fail if there are any received
    }

    func testOnDemandTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(
            player.$properties
                .map(\.playback.timeRange)
                .removeDuplicates(by: close(within: 0.5)),
            values: [
                .invalid,
                CMTimeRangeMake(start: .zero, duration: CMTime(value: 120, timescale: 1))
            ],
            toBe: close(within: 0.5)
        ) {
            player.play()
        }
    }

    func testLiveTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = Player(item: item)
        try expectPublisher(
            player.$properties
                .map(\.playback.timeRange)
                .removeDuplicates(),
            values: [.invalid, .zero]
        ) {
            player.play()
        }
    }

    func testCorruptTimeRange() throws {
        // TODO: Implement expectation which waits for a definite number of values then
        //       wait for other ones and fail if there are any received
    }

    func testUnavailableTimeRange() throws {
        // TODO: Implement expectation which waits for a definite number of values then
        //       wait for other ones and fail if there are any received
    }

    func testProgress() {
        expect(Time.progress(
            for: CMTimeMake(value: 1, timescale: 2),
            in: CMTimeRangeMake(start: .zero, duration: CMTimeMake(value: 1, timescale: 1))
        )).to(equal(0.5))
    }

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
