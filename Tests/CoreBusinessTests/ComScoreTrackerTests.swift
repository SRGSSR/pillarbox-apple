//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import AnalyticsTestBridge
import Nimble
import Player
import XCTest

struct TestMetadata: AssetMetadata {
    let title: String
}

final class ComScoreTrackerTests: ComScoreTestCase {
    func testPlay() {
        expectEqual(values: ["6036016"], for: "c2", during: .seconds(10)) { test in
            let player = Player(item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!, trackerAdapters: [
                ComScoreTracker.adapter(test: test)
            ]))
            player.play()
        }
    }
}
