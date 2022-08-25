//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//


@testable import Player

import AVFoundation
import Nimble
import XCTest

@MainActor
final class PropertiesTimeRangeTests: XCTestCase {
    func testOnDemandTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublished(
            values: [
                .invalid,
                CMTimeRangeMake(start: .zero, duration: CMTime(value: 120, timescale: 1))
            ],
            from: player.$playbackProperties
                .map(\.pulse.timeRange)
                .removeDuplicates(by: beClose(within: 0.5)),
            to: beClose(within: 0.5)
        ) {
            player.play()
        }
    }

    func testLiveTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = Player(item: item)
        try expectPublished(
            values: [.invalid, .zero],
            from: player.$playbackProperties
                .map(\.pulse.timeRange)
                .removeDuplicates()
        ) {
            player.play()
        }
    }

    func testCorruptTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.corruptOnDemandUrl)
        let player = Player(item: item)
        try expectPublished(
            values: [.invalid],
            from: player.$playbackProperties
                .map(\.pulse.timeRange)
                .removeDuplicates(),
            during: 2
        ) {
            player.play()
        }
    }

    func testUnavailableTimeRange() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = Player(item: item)
        try expectPublished(
            values: [.invalid],
            from: player.$playbackProperties
                .map(\.pulse.timeRange)
                .removeDuplicates(),
            during: 2
        ) {
            player.play()
        }
    }
}
