//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import CoreBusiness

import Nimble
import Player
import XCTest

struct TestMetadata: AssetMetadata {
    let title: String
}

final class ComScoreTrackerTests: XCTestCase {
    var testId = UUID().uuidString

    func testPlay() {
        let player = Player(item: .simple(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!, trackerAdapters: [
            ComScoreTracker.adapter(configuration: .init(labels: ["pillarbox_test_id": "12345"]))
        ]))
        player.play()
        let _ = XCTWaiter.wait(for: [XCTestExpectation()], timeout: 10)
    }
}
