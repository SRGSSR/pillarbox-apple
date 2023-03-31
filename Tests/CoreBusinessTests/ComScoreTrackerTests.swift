//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import AnalyticsTestHelpers
import Nimble
import Player
import XCTest

struct TestMetadata: AssetMetadata {
    let title: String
}

final class ComScoreTrackerTests: XCTestCase {
    var testId = UUID().uuidString

    func testPlay() {
        expectEqual(values: ["6036016"], for: "c2", during: .seconds(10)) { sut in
            let player = Player(item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!, trackerAdapters: [
                ComScoreTracker.adapter(sut: sut)
            ]))
            player.play()
        }
    }
}
