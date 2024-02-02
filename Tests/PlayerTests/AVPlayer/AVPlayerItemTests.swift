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

    func testPlayerItems() {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        items.forEach { PlayerItem.load(id: $0.id) }
        let urls = AVPlayerItem.playerItems(from: items, length: 3, fresh: false).compactMap { item -> URL? in
            guard let asset = item.asset as? AVURLAsset else { return nil }
            return asset.url
        }
        expect(urls).to(equal([
            Stream.onDemand.url,
            Stream.shortOnDemand.url,
            Stream.live.url
        ]))
    }
}
