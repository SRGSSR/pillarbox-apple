//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxStreams

final class AVPlayerItemTests: TestCase {
    @MainActor
    func testNonLoadedItem() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        await expect(item.timeRange).toAlways(equal(.invalid), until: .seconds(1))
    }

    @MainActor
    func testOnDemand() async {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        await expect(item.timeRange).toEventuallyNot(equal(.invalid))
    }

    @MainActor
    func testPlayerItemsWithRepeatOff() async {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        await expect {
            AVPlayerItem.playerItems(
                from: items,
                after: 0,
                repeatMode: .off,
                length: .max,
                reload: false,
                configuration: .default,
                resumeState: nil,
                limits: .none
            )
            .compactMap(\.url)
        }
        .toEventually(equal([
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url
        ]))
    }

    @MainActor
    func testPlayerItemsWithRepeatOne() async {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        await expect {
            AVPlayerItem.playerItems(
                from: items,
                after: 0,
                repeatMode: .one,
                length: .max,
                reload: false,
                configuration: .default,
                resumeState: nil,
                limits: .none
            )
            .compactMap(\.url)
        }
        .toEventually(equal([
            Stream.onDemand.url,
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url
        ]))
    }

    @MainActor
    func testPlayerItemsWithRepeatAll() async {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        await expect {
            AVPlayerItem.playerItems(
                from: items,
                after: 0,
                repeatMode: .all,
                length: .max,
                reload: false,
                configuration: .default,
                resumeState: nil,
                limits: .none
            )
            .compactMap(\.url)
        }
        .toEventually(equal([
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url,
            Stream.onDemand.url
        ]))
    }
}
