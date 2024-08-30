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
    func testNonLoadedItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        expect(item.timeRange).toAlways(equal(.invalid), until: .seconds(1))
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(equal(.invalid))
    }

    func testPlayerItemsWithRepeatOff() {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        expect {
            AVPlayerItem.playerItems(from: items, after: 0, repeatMode: .off, length: .max, reload: false).compactMap(\.url)
        }
        .toEventually(equal([
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url
        ]))
    }

    func testPlayerItemsWithRepeatOne() {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        expect {
            AVPlayerItem.playerItems(from: items, after: 0, repeatMode: .one, length: .max, reload: false).compactMap(\.url)
        }
        .toEventually(equal([
            Stream.onDemand.url,
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url
        ]))
    }

    func testPlayerItemsWithRepeatAll() {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        expect {
            AVPlayerItem.playerItems(from: items, after: 0, repeatMode: .all, length: .max, reload: false).compactMap(\.url)
        }
        .toEventually(equal([
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url,
            Stream.onDemand.url
        ]))
    }
}
