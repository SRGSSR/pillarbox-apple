//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import Streams

final class AVPlayerTests: TestCase {
    func testTimeRangeWhenEmpty() {
        let player = AVPlayer()
        expect(player.timeRange).to(equal(.invalid))
    }

    func testTimeRangeForOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expect(player.timeRange).toEventually(equal(CMTimeRange(start: .zero, duration: Stream.onDemand.duration)))
    }

    func testDurationWhenEmpty() {
        let player = AVPlayer()
        expect(player.duration).to(equal(.invalid))
    }

    func testDurationForOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expect(player.duration).to(equal(.invalid))
        expect(player.duration).toEventually(equal(Stream.onDemand.duration))
    }

    func testDurationForLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expect(player.duration).to(equal(.invalid))
        expect(player.duration).toEventually(equal(.indefinite))
    }

    func testDurationForDvr() {
        let item = AVPlayerItem(url: Stream.dvr.url)
        let player = AVPlayer(playerItem: item)
        expect(player.duration).to(equal(.invalid))
        expect(player.duration).toEventually(equal(.indefinite))
    }
}
