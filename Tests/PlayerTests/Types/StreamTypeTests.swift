//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import Streams

final class StreamTypeTests: TestCase {
    func testUnknown() {
        let player = Player()
        expect(player.streamType).toAlways(equal(.unknown), until: .seconds(2))
    }

    func testLiveIsLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
    }

    func testLiveIsNeverDvr() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toNever(equal(.dvr), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testLiveIsNeverOnDemand() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toNever(equal(.onDemand), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testDvrIsDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
    }

    func testDvrIsNeverLive() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toNever(equal(.live), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testDvrIsNeverOnDemand() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toNever(equal(.onDemand), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testOnDemandIsOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
    }

    func testOnDemandIsNeverLive() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toNever(equal(.live), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testOnDemandIsNeverDvr() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toNever(equal(.dvr), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testOnDemandMp3IsOnDemand() {
        let player = Player(item: .simple(url: Stream.mp3.url))
        expect(player.streamType).toEventually(equal(.onDemand))
    }

    func testOnDemandMp3IsNeverLive() {
        let player = Player(item: .simple(url: Stream.mp3.url))
        expect(player.streamType).toNever(equal(.live), until: .seconds(1), pollInterval: .microseconds(1))
    }

    func testOnDemandMp3IsNeverDvr() {
        let player = Player(item: .simple(url: Stream.mp3.url))
        expect(player.streamType).toNever(equal(.dvr), until: .seconds(1), pollInterval: .microseconds(1))
    }
}
