//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class AVPlayerItemTests: XCTestCase {
    func testNonLoadedItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        expect(item.timeRange).toAlways(beNil())
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expect(item.timeRange).toEventuallyNot(beNil())
    }

    func testPlayerItems() {
        let items = [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url),
            PlayerItem.simple(url: Stream.live.url)
        ]
        let urls = AVPlayerItem.playerItems(from: items).compactMap { item -> URL? in
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
