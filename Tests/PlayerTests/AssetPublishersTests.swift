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
        let asset = AVURLAsset(url: TestStreams.onDemandUrl)

        let duration1 = waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration1).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))

        let duration2 = waitForSingleOutput(from: asset.propertyPublisher(.duration))
        expect(duration2).to(equal(CMTime(value: 120, timescale: 1), by: beClose(within: 0.5)))
    }

    func testInvalidStream() {
        let asset = AVURLAsset(url: TestStreams.unavailableUrl)
        let error = waitForFailure(from: asset.propertyPublisher(.duration))
        expect(error).notTo(beNil())
    }
}
