//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class AVPlayerTests: TestCase {
    func testTimeRangeWhenEmpty() {
        let player = AVPlayer()
        expect(player.timeRange).to(equal(.invalid))
    }

    @MainActor
    func testTimeRangeForOnDemand() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        await expect(player.timeRange).toEventually(equal(CMTimeRange(start: .zero, duration: Stream.onDemand.duration)))
    }

    func testDurationWhenEmpty() {
        let player = AVPlayer()
        expect(player.duration).to(equal(.invalid))
    }

    @MainActor
    func testDurationForOnDemand() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expect(player.duration).to(equal(.invalid))
        await expect(player.duration).toEventually(equal(Stream.onDemand.duration))
    }

    @MainActor
    func testDurationForLive() async {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expect(player.duration).to(equal(.invalid))
        await expect(player.duration).toEventually(equal(.indefinite))
    }

    @MainActor
    func testDurationForDvr() async {
        let item = AVPlayerItem(url: Stream.dvr.url)
        let player = AVPlayer(playerItem: item)
        expect(player.duration).to(equal(.invalid))
        await expect(player.duration).toEventually(equal(.indefinite))
    }
}
