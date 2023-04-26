//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import Streams
import XCTest

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

    func testItemDurationWhenEmpty() {
        let player = AVPlayer()
        expect(player.itemDuration).to(equal(.invalid))
    }

    func testItemDurationForOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expect(player.itemDuration).to(equal(.invalid))
        expect(player.itemDuration).toEventually(equal(Stream.onDemand.duration))
    }

    func testItemDurationForLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expect(player.itemDuration).to(equal(.invalid))
        expect(player.itemDuration).toEventually(equal(.indefinite))
    }

    func testItemDurationForDvr() {
        let item = AVPlayerItem(url: Stream.dvr.url)
        let player = AVPlayer(playerItem: item)
        expect(player.itemDuration).to(equal(.invalid))
        expect(player.itemDuration).toEventually(equal(.indefinite))
    }
}
