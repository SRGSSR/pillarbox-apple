//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble
import XCTest

final class PlayerTests: XCTestCase {
    func testConstants() {
        expect(Player.startTimeThreshold).to(equal(3))
    }

    func testDeallocation() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testStreamTypeWhenTimeRangeAndItemDurationAreInvalid() {
        let streamType = Player.streamType(for: .invalid, itemDuration: .invalid)
        expect(streamType).to(equal(.unknown))
    }

    func testStreamTypeWhenTimeRangeIsEmpty() {
        let streamType = Player.streamType(for: .zero, itemDuration: .indefinite)
        expect(streamType).to(equal(.live))
    }

    func testStreamTypeWhenItemDurationIsIndefinite() {
        let start = CMTime(value: 0, timescale: 1)
        let end = CMTime(value: 1, timescale: 1)
        let streamType = Player.streamType(for: .init(start: start, end: end), itemDuration: .indefinite)
        expect(streamType).to(equal(.dvr))
    }

    func testStreamTypeWhenTimeRangeIsNotEmptyAndItemDurationIsZero() {
        let start = CMTime(value: 0, timescale: 1)
        let end = CMTime(value: 1, timescale: 1)
        let streamType = Player.streamType(for: .init(start: start, end: end), itemDuration: .zero)
        expect(streamType).to(equal(.live))
    }

    func testStreamTypeWhenTimeRangeIsNotEmptyAndItemDurationIsDefinedAndNotZero() {
        let start = CMTime(value: 0, timescale: 1)
        let end = CMTime(value: 1, timescale: 1)
        let streamType = Player.streamType(for: .init(start: start, end: end), itemDuration: end)
        expect(streamType).to(equal(.onDemand))
    }
}
