//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

@MainActor
final class PlayerStreamTypeTests: XCTestCase {
    func testEmpty() {
        let player = Player()
        expect(player.streamType).toAlways(equal(.unknown))
    }

    func testOnDemand() {
        let item = PlayerItem(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.onDemand))
    }

    func testLive() {
        let item = PlayerItem(url: Stream.live.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.live))
    }

    func testDVR() {
        let item = PlayerItem(url: Stream.dvr.url)
        let player = Player(item: item)
        expect(player.streamType).toEventually(equal(.dvr))
    }

    func testStabilityAtStart() {
        let item = PlayerItem(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.streamType).toNever(equal(.dvr), pollInterval: .microseconds(1))
    }

    func testStabilityAtStartWithoutAutomaticallyLoadedAssetKeys() {
        let item = PlayerItem(url: Stream.onDemand.url, automaticallyLoadedAssetKeys: [])
        let player = Player(item: item)
        expect(player.streamType).toNever(equal(.dvr), pollInterval: .microseconds(1))
    }
}
