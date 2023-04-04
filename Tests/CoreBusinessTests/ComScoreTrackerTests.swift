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
        let player = Player()
        expectEqual(values: ["play"], for: "ns_st_ev", during: .seconds(10)) { test in
            player.append(.simple(
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!,
                trackerAdapters: [
                    ComScoreTracker.adapter(test: test)
                ]
            ))
            player.play()
        }
    }
}
