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

final class AssetPublishersTests: XCTestCase {
    func testFetch() {
        let asset = AVURLAsset(url: TestStreams.onDemandUrl)
        let duration = waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))
    }

    func testRepeatedFetch() {

    }

    func testInvalidStream() {
        
    }

    func testDeallocation() {

    }
}
